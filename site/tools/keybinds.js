// BINDINGS:
// nj  -> scroll down n times, n::int, default n=1
// nk  -> 
// h,l -> prev, next (chapter)
// ←,→ -> prev, next (chapter)
// r   -> reload
// H,L -> prev, next (history)
// T   -> toggle night mode [wip]
// gg  -> go to top
// ng  -> scroll to n%, n::int, default n=100
// nG  -> scroll to n%, n::int, default n=100

var prev=null;

document.addEventListener('keydown', (event) => {
  var key=`${event.key}`;
	console.log(prev, key);
  var source=event.target;
  let exclude=['input', 'textarea'];
  let excludeKeys = ['Shift', 'ArrowUp', 'ArrowDown', 'Alt'];

  if (exclude.indexOf(source.tagName.toLowerCase())===-1 &&
      ! excludeKeys.includes(key)) {
	       if ('j'==key) {
	        if (!isNaN(parseInt(prev))) {window.scrollBy({top: 40*prev});} 
		       else {window.scrollBy({top: 40});}
  	} else if ('k'==key) {
	        if (!isNaN(parseInt(prev))) {window.scrollBy({top: -40*prev});}
		       else {window.scrollBy({top: -40});}
  	} else if ('h'==key) {
	        document.getElementById('prev').click();
  	} else if ('l'==key) {
	        document.getElementById('next').click();
  	} else if ('ArrowLeft'==key) {
	        document.getElementById('prev').click();
  	} else if ('ArrowRight'==key) {
	        document.getElementById('next').click();
  	} else if ('r'==key) {
  		location.reload();
  	} else if ('H'==key) {
  		window.history.back();    
  	} else if ('L'==key) {
  		window.history.forward();
  	} else if ('T'==key) { 
		console.log('wip');       // need to write css for light
        } else if ('g'==key && 'g'==prev) {
  		window.scrollTo({top: 0});
  	} else if ('G'==key || 'g'==key) {
	       if (!isNaN(parseInt(prev))) {
        window.scrollTo({top: (document.body.scrollHeight*(prev/100)-(screen.height/2))})
      } else {
        window.scrollTo({top: document.body.scrollHeight})
      }
    }
    if (!isNaN(parseInt(key)) && !isNaN(parseInt(prev))) {
      prev=parseInt(""+prev+key)
    } else {
      prev=key;
    }
  }
}
)

