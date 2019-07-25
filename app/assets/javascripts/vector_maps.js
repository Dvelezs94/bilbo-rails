$(function(){
  'use strict'
$('#vmap').vectorMap({
  map: 'mx_en',
  showTooltip: true,
  backgroundColor: '#fff',
  color: '#d1e6fa',
  colors: {
    qro: '#69b2f8',
    coah: '#69b2f8',
    nl: '#69b2f8',
    tamps: '#69b2f8'
  },
  selectedColor: '#00cccc',
  enableZoom: false,
  borderWidth: 1,
  borderColor: '#fff',
  hoverOpacity: .85
});
});
