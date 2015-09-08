
function setupInfo(){
    var infos = document.getElementsByClassName('tile_info');
    for(var i=0; i<infos.length; i++){
        infos[i].onclick=function(){
            this.style.right='-600px';
        }
        //infos[i].onmouseout=function(){
        //    this.style.right='-600px';
        //}
    }
}

function hideAllTileInfo(){
    var infos = document.getElementsByClassName('tile_info');
    for(var i=0; i<infos.length; i++){
        infos[i].style.right='-600px';
    }
}

function buildTiles(){
    var ul = document.getElementsByClassName('tile_container');
    for(var i=0; i<ul.length; i++){
        var lis = ul[i].getElementsByTagName('li');
        for(var j=0; j<lis.length; j++){
            var li=lis[j];
            li.onmouseover = function(){
                this.getElementsByTagName('p')[0].style.top='-120%';
            }

            li.getElementsByTagName('p')[0].onmouseout=function(){
                this.style.top='0%';
            }

            li.getElementsByTagName('p')[0].onclick=function(){
                hideAllTileInfo();
                var small = this.parentNode.getElementsByTagName('a')[0];
                var info = document.getElementById(small.id.concat('_info'));
                info.style.right='0px';
            }

        }
    }

}

setupInfo();
buildTiles();
