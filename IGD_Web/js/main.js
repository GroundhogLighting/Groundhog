function getId(content){
    return content.split(' ').join('_').toLowerCase();
}

function buildSocial(){

    var social = document.createElement('div');
    social.id='social';

    var ul = document.createElement('ul');
    ul.className='dropDownMenu';

    var linkedin_li=document.createElement('li');
    var linkedin_a=document.createElement('a');
    linkedin_a.id='linkedin';
    linkedin_a.href='https://www.linkedin.com/company/igd-chile'
    linkedin_li.appendChild(linkedin_a);
    ul.appendChild(linkedin_li);

    var mail_li=document.createElement('li');
    var mail_a=document.createElement('a');
    mail_a.id='mailto';
    mail_a.href='mailto:gmolina@igd.cl';
    mail_a.textContent='gmolina@igd.cl';
    mail_li.appendChild(mail_a);
    ul.appendChild(mail_li);

    social.appendChild(ul);
    document.body.appendChild(social);

}

//BUILD HE MENU
function buildMenu(){

    var h1=['Home','Quienes somos','Que hacemos','Curriculum','Ideas','Contacto'];


    var menu_div = document.createElement('div');
    menu_div.id='navigation';
    var menu = document.createElement('ul');
    menu.id='menu';
    menu.className='dropDownMenu';


    //add menu (responsive)
    var anchor = document.createElement('a');
    anchor.href='#';
    anchor.id='mobile_menu';
    anchor.textContent='Menu';
    anchor.className='with_icon';
    menu_div.appendChild(anchor);
    anchor.onclick=function (){
        var menu=document.getElementById('menu');
        var left = window.getComputedStyle(menu,null).getPropertyValue('left');
        if(left=='0px'){
            menu.style.left='-300px';
        }else{
            menu.style.left='0px';
        }
    }


    //add home
    var anchor = document.createElement('a');
    anchor.href='index.html';
    anchor.textContent=h1[0];
    anchor.className='with_icon';
    anchor.id='home_button'
    var elem=document.createElement('li');
    elem.appendChild(anchor);
    menu.appendChild(elem);

    //add the rest
    for(var i=1; i<h1.length; i++){

         var anchor = document.createElement('a');
         anchor.href=getId(h1[i].concat('.html'));//'#'.concat(getId(h1[i]).textContent));
         anchor.textContent=h1[i];//.textContent;

         var elem=document.createElement('li');
         elem.appendChild(anchor);
         menu.appendChild(elem);
     }

     menu_div.appendChild(menu);
     document.body.appendChild(menu_div);
}

buildMenu();
buildSocial();
