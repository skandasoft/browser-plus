if (location.href.startsWith('data:text/html,')) {

}else{
  console.log("~browser-plus-href~"+location.href + " "+document.title);
}
if( typeof jQuery == 'undefined'){
  console.log("~browser-plus-jquery~")
}
