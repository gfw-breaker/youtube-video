<script>

function getSubSet(arr, size) {
    var shuffled = arr.slice(0), i = arr.length, temp, index;
    while (i--) {
        index = Math.floor((i + 1) * Math.random());
        temp = shuffled[index];
        shuffled[index] = shuffled[i];
        shuffled[i] = temp;
    }
    return shuffled.slice(0, size);
}


$.ajax({
    url:"http://gfw-breaker.win/videos/videos.json",
    type:"get",
    dataType:'json',
    success:function (json) {
	subSet = getSubSet(json, 3)
        for(i in subSet) {
		v = subSet[i]
		ele = `<div><a href='${v.id}'>${v.title}</a><br/></div>`
		$("#anchor").after(ele);
	}
    },
    error:function (e) {
        console.log(e.message);
    }
});

$.ajax({
    url:"http://gfw-breaker.win/videos/link.json",
    type:"get",
    dataType:'json',
    success:function (json) {
	subSet = getSubSet(json, 3)
        for(i in subSet) {
		v = subSet[i]
		ele = `<div><a href='${web}${v.url}'>${v.title}</a><br/></div>`
		$("#anchor").after(ele);
	}
    },
    error:function (e) {
        console.log(e.message);
    }
});
</script>
