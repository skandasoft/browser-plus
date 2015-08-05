console.log("~browser-plus-title~ "+document.title);
if (location.href.includes('data:text/html,')) {
  
}else{
  console.log("~browser-plus-href~"+location.href);
}

setTimeout(function(){
  console.log("~browser-plus-title~ "+document.title);
},300)
window.onload = function(e){
    console.log("~browser-plus-title~ "+document.title);
}
