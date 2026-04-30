#!/usr/bin/env python3
import asyncio
import json
import os
import time

import aiohttp

COMFY_HTTP = os.environ.get("COMFY_HTTP", "http://127.0.0.1:8188").rstrip("/")
OUT_FILE = os.environ.get("COMFY_WAYBAR_OUT", "/tmp/comfy_progress.json")
CLIENT_ID = os.environ.get("COMFY_CLIENT_ID", "waybar")  # <- FIJO
POLL_QUEUE_EVERY = float(os.environ.get("COMFY_POLL_QUEUE_EVERY", "2.0"))

def now_ts() -> float:
    return time.time()

def atomic_write_json(path: str, data: dict) -> None:
    tmp = f"{path}.tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False)
    os.replace(tmp, path)

async def fetch_queue(session: aiohttp.ClientSession) -> tuple[int, int]:
    try:
        async with session.get(f"{COMFY_HTTP}/queue", timeout=aiohttp.ClientTimeout(total=2)) as r:
            r.raise_for_status()
            q = await r.json()
            pending = len(q.get("pending", [])) if isinstance(q, dict) else 0
            running = len(q.get("running", [])) if isinstance(q, dict) else 0
            return pending, running
    except Exception:
        return 0, 0

def http_to_ws_url(http_url: str) -> str:
    if http_url.startswith("https://"):
        return "wss://" + http_url[len("https://"):]
    if http_url.startswith("http://"):
        return "ws://" + http_url[len("http://"):]
    # fallback
    return "ws://" + http_url

def set_status_from_queue(state: dict) -> None:
    # Si no hay WS activo, esta heurística mantiene un estado útil para Waybar.
    if state.get("status") == "running":
        return
    if (state.get("queue_running", 0) or 0) > 0:
        state["status"] = "running"
    elif (state.get("queue_pending", 0) or 0) > 0:
        state["status"] = "queued"
    else:
        state["status"] = "idle"

async def queue_poller(state: dict, stop_evt: asyncio.Event):
    async with aiohttp.ClientSession() as session:
        while not stop_evt.is_set():
            pending, running = await fetch_queue(session)
            state["queue_pending"] = pending
            state["queue_running"] = running
            # Solo ajusta estado si no hay info mejor del WS
            set_status_from_queue(state)
            state["updated_at"] = now_ts()
            atomic_write_json(OUT_FILE, state)
            await asyncio.sleep(POLL_QUEUE_EVERY)

def update_from_ws_message(state: dict, msg: dict) -> None:
    """
    ComfyUI suele mandar:
      {"type":"progress","data":{"value":x,"max":y}}
      {"type":"executing","data":{"node":"...","prompt_id":"..."}}
      {"type":"status","data":{...}}
    Pero toleramos variaciones.
    """
    mtype = msg.get("type")
    data = msg.get("data") if isinstance(msg.get("data"), dict) else {}

    # progreso
    if mtype == "progress":
        value = data.get("value")
        maxv = data.get("max")
        state["value"] = value
        state["max"] = maxv
        if isinstance(value, (int, float)) and isinstance(maxv, (int, float)) and maxv:
            state["percent"] = int(round((value / maxv) * 100))
        state["status"] = "running"

    # nodo actual / fin
    if mtype == "executing":
        node = data.get("node")
        prompt_id = data.get("prompt_id")
        if prompt_id is not None:
            state["prompt_id"] = str(prompt_id)
        if node is None:
            # Cuando termina, Comfy a veces manda executing con node:null
            state["status"] = "idle"
            state["percent"] = None
            state["value"] = None
            state["max"] = None
            state["node"] = None
        else:
            state["node"] = str(node)
            state["status"] = "running"

    # algunos builds mandan status con info de ejecución / cola
    if mtype == "status":
        # No depende de su estructura, pero si hay cola la reflejamos
        # (y evitamos pisar un running real)
        set_status_from_queue(state)

async def main():
    ws_base = http_to_ws_url(COMFY_HTTP)
    ws_url = f"{ws_base}/ws?clientId={CLIENT_ID}"

    state = {
        "status": "starting",
        "percent": None,
        "value": None,
        "max": None,
        "node": None,
        "prompt_id": None,
        "queue_pending": 0,
        "queue_running": 0,
        "updated_at": now_ts(),
        "client_id": CLIENT_ID,
        "ws_url": ws_url,
    }
    atomic_write_json(OUT_FILE, state)

    stop_evt = asyncio.Event()
    poll_task = asyncio.create_task(queue_poller(state, stop_evt))

    backoff = 0.5
    while True:
        try:
            state["status"] = "connecting"
            state["updated_at"] = now_ts()
            atomic_write_json(OUT_FILE, state)

            async with aiohttp.ClientSession() as session:
                async with session.ws_connect(ws_url, heartbeat=15) as ws:
                    state["status"] = "connected"
                    state["updated_at"] = now_ts()
                    atomic_write_json(OUT_FILE, state)

                    backoff = 0.5
                    async for m in ws:
                        if m.type == aiohttp.WSMsgType.TEXT:
                            try:
                                msg = json.loads(m.data)
                            except Exception:
                                continue
                            if isinstance(msg, dict):
                                update_from_ws_message(state, msg)
                                state["updated_at"] = now_ts()
                                atomic_write_json(OUT_FILE, state)
                        elif m.type in (aiohttp.WSMsgType.CLOSED, aiohttp.WSMsgType.ERROR):
                            break

        except Exception:
            # OJO: Comfy puede cerrar el WS sin “problema”; no queremos parpadear feo.
            # Dejamos que el poller de /queue determine idle/queued/running.
            state["ws_state"] = "disconnected"
            state["updated_at"] = now_ts()
            atomic_write_json(OUT_FILE, state)

            await asyncio.sleep(backoff)
            backoff = min(backoff * 1.7, 10.0)

if __name__ == "__main__":
    asyncio.run(main())
