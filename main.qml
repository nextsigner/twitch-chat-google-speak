import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Window 2.0
import QtMultimedia 5.12
import QtWebView 1.1
import Qt.labs.settings 1.1
import unik.UnikQProcess 1.0
import unik.Unik 1.0

ApplicationWindow{
    id: app
    visible: true
    visibility: "Maximized"
    color: '#ccc'//'transparent'
    title: 'Twicht Chat Speech'
    property int fs: width*0.02
    property string userAdmin: 'RicardoMartinPizarro'
    onClosing: {
        close.accepted = true
        Qt.quit()
    }
    onVisibilityChanged: {
        if(app.visibility===ApplicationWindow.Maximized){
            //app.editable=!app.editable
            //showMode(app.editable)
        }
    }
    Unik{id: unik}
    Audio {
        id: mpRing
        source: 'file:/home/ns/nsp/uda/twitch-chat/sounds/ring_1.mp3';
        autoLoad: true
        autoPlay: true
    }
    Audio {
        id: mp2
        //source: 'file:/home/ns/nsp/uda/twitch-chat/sounds/ring_1.mp3';
        //autoLoad: true
        //autoPlay: true
        onPlaybackStateChanged:{
            if(mp2.playbackState===Audio.StoppedState){
                playlist2.removeItem(0)
            }
        }
        playlist: Playlist {
            id: playlist2
            onItemCountChanged:{
                //xMsgList.actualizar(playlist)
            }
        }
    }
    Audio {
        id: mp;
        onPlaybackStateChanged:{
            if(mp.playbackState===Audio.StoppedState){
                playlist.removeItem(0)
            }
        }
        playlist: Playlist {
            id: playlist
            onItemCountChanged:{
                xMsgList.actualizar(playlist)
            }
        }
    }
    Settings{
        id: apps
        property string uHtml: ''        
    }
    Item{
        id: xAppWV
        anchors.fill: parent
        //opacity: app.editable?1.0:0.65
        WebView{
            id: wv
            width: parent.width
            height: parent.height//*0.5
            x:500//app.width+1280
            //            y: 100
            //url:"https://streamlabs.com/widgets/chat-box/v1/15602D8555920F741CDF"
            //url:"https://twitch.tv/ricardomartinpizarro/chat"

            //visible:false
            onLoadProgressChanged:{
                if(loadProgress===100){
                    //tCheck.start()
                }
            }
        }
    }
    Item{
        id: xApp
        anchors.fill: parent
        ListView{
            id: lv
            width: 500
            height: 500
            spacing: 4
            delegate: compItem
            model: lm
            /*Rectangle{
                anchors.fill: parent
                color: 'green'
            }*/
            ListModel{
                id: lm
                function add(f, m){
                    return {
                        from: f,
                        msg: m
                    }
                }
            }
            Component{
                id: compItem
                Rectangle{
                    id: xItem
                    width: 500//lv.width
                    height: 100//txt1.contentHeight//*1.1
                    color: 'black'
                    border.width: 2
                    border.color: 'red'
                    // Componente para reproducir el audio
                    Audio {
                        id: playMusic
                        onStatusChanged: {
                                if (playMusic.status === Audio.EndOfMedia) {
                                    //console.log("¡El audio ha terminado de reproducirse!");
                                    tClose.start()
                                }
                            }

                            // Opcional: Manejo de errores de red o formato
                            onError: {
                                console.error("Error de reproducción: " + errorString);
                            }
                    }
                    Text{
                        id: txt1
                        text: from +': '+msg
                        width: parent.width*0.9
                        wrapMode: Text.WordWrap
                        color: 'white'
                        anchors.centerIn: parent
                    }
                    Timer{
                        id: tClose
                        running: false
                        repeat: false
                        interval: 2000
                        onTriggered: {
                            lm.remove(index)
                        }
                    }
                    Timer{
                        id: tPlay
                        running: index===0
                        repeat: false
                        interval: 2000
                        onTriggered: {
                            playMusic.play();
                        }
                    }
                    Component.onCompleted: {
                        //lv.currentIndex=index
                        var lang = "es"; // Código de idioma
                        var texto = encodeURIComponent(from+' dice '+msg);

                        // Usamos el endpoint de Google Translate (uso educativo/personal)
                        var url = "https://translate.google.com/translate_tts?ie=UTF-8&q="
                                  + texto + "&tl=" + lang + "&client=tw-ob";

                        // En lugar de una petición compleja, podemos asignar la URL directamente
                        // al componente Audio, ya que Qt Multimedia maneja el stream.
                        playMusic.source = url;
                        //playMusic.play();
                    }
                }
            }
        }
    }
    property string uMsg: 'null'
    Timer{
        id: tCheck
        running: true
        repeat: true
        interval: 1000
        property int v: 0
        property bool e: false
        onTriggered: {
            running=false
            wv.runJavaScript('function doc(){var d=document.body.innerHTML; return d;};doc();', function(html){
                //console.log('Doc: '+html)
                //lm.append(lm.add(html, ''))
                if(html&&html!==apps.uHtml){
                    if(html.indexOf(':')>=0){
                        console.log('yes'+tCheck.v)

                        tCheck.v++
                        if(tCheck.v >=1){
                            let m0 = html.split('author__')//html.replace(/<[^>]+>/g, '');
                            //console.log('Html:'+html)
                            if(m0.length>0){
                                //console.log('Html:'+m0[m0.length-1])
                                let m1=m0[m0.length-1].split(';">')
                                if(m1.length>0){
                                    let m2=m1[1].split('<')
                                    //console.log('De:'+m2[0])
                                    let m3=m0[1].split('text">')
                                    //console.log('m2 1:'+m1[1])
                                    if(m3.length>0){
                                        let m4=m1[1].split('chat-message-text">')
                                        //console.log('m4[1]:'+m4[1])
                                        if(m4.length>0){
                                            let m5=m4[1].split('<')
                                            let de=m2[0]
                                            let msg=m5[0]
                                            console.log('De:'+de)
                                            console.log('Dice:'+msg)


                                            if(de.indexOf(app.userAdmin)>=0 && msg.indexOf('eqmlnot')>=0){
                                                tCheck.e=true
//                                                apps.uHtml=html
//                                                running=true
//                                                return
                                            }
                                            if(de.indexOf(app.userAdmin)>=0 && msg.indexOf('dqmlnot')>=0){
                                                tCheck.e=false
                                                //apps.uHtml=html
                                                //running=true
                                                //return
                                            }
                                            apps.uHtml=html
                                            console.log('Enabled for sending:'+e)
                                            let umsg=''+de+'_'+msg
                                            if(app.uMsg!==umsg){
                                                app.uMsg=umsg
                                                lm.append(lm.add(de, msg))
                                                //return
                                            }
                                            if(tCheck.e){
                                                //Qt.quit()
                                                //sendNot(de, msg)
                                                //running=true
                                                return
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }
                }else{
                    //unik.speak('NO')
                    //apps.uHtml=''
                    running=true
                    //return
                }
                apps.uHtml=html
                running=true
            });
            running=true
        }
    }



    Shortcut{
        sequence: 'Esc'
        onActivated: {

        }
    }
    UnikQProcess{
        id: uqp
        onLogDataChanged: {
            console.log('LogData: '+logData)
            tCheck.running=true
        }
    }
    Component.onCompleted: {
        let args=Qt.application.arguments
        console.log('Args: '+args)
        for(var i=0;i<args.length;i++){
            var m0
            let arg=args[i]
            if(arg.indexOf('-urlChat=')>=0){
                m0=arg.split('-urlChat=')
                wv.url=m0[1]
                console.log('wv.url: '+wv.url)
            }else{
                wv.url="https://twitch.tv/ricardomartinpizarro/chat"
            }
            console.log('Args: '+args)
        }
    }
    function sendNot(from, msg){
        tCheck.running=false
        let d=new Date(Date.now())
        let sd=''+d.getDate()+'/'+parseInt(d.getMonth()+1)+'/'+d.getFullYear()
        let sh=''+d.getHours()+':'+d.getMinutes()+'hs'
        let s='Nuevo mensaje en el chat de Twitch - '+sd+' '+sh+'De: '+from+' Mensaje: '+msg
        let cmd='sh '
        cmd+=' /home/ns/gd/scripts/sendPushoverTwitchAlert.sh "'+s+'"'

        lm.append(lm.add(from, msg))

        /*
        #!/bin/bash
        curl -s   --form-string "token=appPushovertoken"   --form-string "user=<userPushoverid>"   --form-string "message=$1"   https://api.pushover.net/1/messages.json
        */
        //uqp.run(cmd)
    }
    Shortcut{
        sequence: '*'
        onActivated: {
            lm.append(lm.add('AAA', 'BBB'))
        }
    }
}
