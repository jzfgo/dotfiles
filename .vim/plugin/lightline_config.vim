let g:lightline = { 'colorscheme': 'palenight' }

augroup LightlineCustom
  autocmd!
  autocmd VimEnter * call SetupLightlineColors()
augroup END

function SetupLightlineColors() abort
  " Obtenemos la paleta original de palenight
  let l:palette = lightline#palette()

  " Definimos el color de acento de palenight (por ejemplo, el lila/azul)
  " pero ponemos 'NONE' en el segundo y cuarto valor (fondos)
  let l:palette.normal.left = [ [ '#ab47bc', 'NONE', 5, 'NONE' ] ]
  let l:palette.normal.middle = [ [ '#bfc9db', 'NONE', 7, 'NONE' ] ]
  let l:palette.normal.right = [ [ '#ab47bc', 'NONE', 5, 'NONE' ] ]

  " Hacemos lo mismo para el resto de modos o los igualamos al normal
  let l:palette.insert.left = [ [ '#82aaff', 'NONE', 4, 'NONE' ] ]
  let l:palette.visual.left = [ [ '#c792ea', 'NONE', 13, 'NONE' ] ]
  let l:palette.tabline.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]

  call lightline#colorscheme()
endfunction

