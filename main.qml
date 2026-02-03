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
    color: '#000'//'transparent'
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
    Unik{id: u}
    Audio {
        id: mpRing
        source: u.currentFolderPath()+'/sounds/ring_1.mp3';
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
            width: parent.width*0.5
            height: parent.height//*0.5
            x:app.width*0.5//+1280
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
        Column{
            spacing: 10
            width: parent.width
            ListView{
                id: lv
                width: app.width*0.5
                height: app.height*0.5
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
                        // ... (tus propiedades de ancho, alto y color se mantienen igual)

                        // --- NUEVAS PROPIEDADES PARA EL MANEJO DE FRAGMENTOS ---
                        property var chunks: []
                        property int currentChunk: 0

                        function playNextChunk() {
                            if (currentChunk < chunks.length) {
                                var lang = "es";
                                var texto = encodeURIComponent(chunks[currentChunk]);
                                var url = "https://translate.google.com/translate_tts?ie=UTF-8&q="
                                        + texto + "&tl=" + lang + "&client=tw-ob";

                                playMusic.source = url;
                                playMusic.play();
                                currentChunk++;
                            } else {
                                // Ya no hay más partes, iniciamos el timer para eliminar el item
                                tClose.start();
                            }
                        }

                        Audio {
                            id: playMusic
                            onStatusChanged: {
                                if (playMusic.status === Audio.EndOfMedia) {
                                    // En lugar de cerrar directo, intentamos el siguiente fragmento
                                    xItem.playNextChunk();
                                }
                            }
                            onError: {
                                console.error("Error TTS: " + errorString);
                                xItem.playNextChunk(); // Saltar al siguiente si este falló
                            }
                        }

                        // ... (Tus otros componentes Text y Timers)

                        Component.onCompleted: {
                            let fullText = from + ' dice ' + msg;

                            // Lógica de fragmentación (200 caracteres máximo)
                            let maxLen = 180; // Usamos 180 para estar seguros con caracteres especiales
                            let regex = new RegExp('.{1,' + maxLen + '}(\\s|$)|.{1,' + maxLen + '}', 'g');
                            chunks = fullText.match(regex);

                            // El Timer tPlay ahora solo dispara la primera parte
                        }

                        Timer{
                            id: tPlay
                            running: index === 0
                            repeat: false
                            interval: 1000
                            onTriggered: {
                                xItem.playNextChunk();
                            }
                        }
                    }
                }

            }
            ListView{
                id: lvUsers
                width: app.width*0.5-parent.spacing
                height: app.height*0.5
                spacing: 4
                delegate: compItemUser
                model: lmUsers
                ListModel{
                    id: lmUsers
                    function add(l){
                        return {
                            line: l
                        }
                    }
                }
                Component{
                    id: compItemUser
                    Rectangle{
                        id: xItem
                        width: lv.width
                        height: 30
                        color: 'black'
                        border.width: 2
                        border.color: 'red'
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                let user=line.split(' ')[0]
                                toogleUserIsEnabled(user)
                            }
                        }
                        Rectangle{
                            width: parent.height*0.5
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    deleteUser(line.replace(' true', '').replace(' false', ''))
                                }
                            }
                            Text{
                                text: 'X'
                                font.pixelSize: parent.width*0.8
                                color: 'black'
                                anchors.centerIn: parent
                            }
                        }
                        Text{
                            id: txt1
                            text: line
                            width: parent.width*0.9
                            wrapMode: Text.WordWrap
                            color: 'white'
                            anchors.centerIn: parent
                        }
                        Component.onCompleted: {
                            let e=line.indexOf(' true')>=0
                            if(e){
                                xItem.color='green'
                            }else{
                                xItem.color='red'
                            }
                        }
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
                                                let userIndex=getUserIndex(de)
                                                console.log('Usuario index: '+userIndex)
                                                if(userIndex===-1){
                                                    addUser(de)
                                                    lm.append(lm.add(de, msg.replace(/\n/g, '').replace(/\r/g, '').replace(/\t/g, '')))
                                                }
                                                if(userIsEnabled(de))lm.append(lm.add(de, msg))
                                                //return
                                            }
                                            if(tCheck.e){
                                                //Qt.quit()
                                                sendNot(de, msg)
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



    UnikQProcess{
        id: uqp
        onLogDataChanged: {
            console.log('LogData: '+logData)
            tCheck.running=true
        }
    }
    Component.onCompleted: {
        updateUsersList()
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
            //sendPushoverMessage('Se inicia pushOver en Twitch Chat Goolge Speak')
            //sendNot(app.title, 'Iniciado 2')
            mpRing.play()
        }
    }
    Shortcut{
        sequence: 'Esc'
        onActivated: {

        }
    }
    Shortcut{
        sequence: '*'
        onActivated: {
            lm.append(lm.add('AAA', 'BBB'))
        }
    }
    function sendNot(from, msg){
        tCheck.running=false
        let pushoverFileData=u.getFile('pushover')
        if(pushoverFileData==='error')return
        let mPushOver=pushoverFileData.split('\n')
        console.log('PushOver data: '+pushoverFileData)
        let d=new Date(Date.now())
        let sd=''+d.getDate()+'/'+parseInt(d.getMonth()+1)+'/'+d.getFullYear()
        let sh=''+d.getHours()+':'+d.getMinutes()+'hs'
        let s='Nuevo mensaje en el chat de Twitch - '+sd+' '+sh+'De: '+from+' Mensaje: '+msg
        let cmd='sh '
        cmd+=' sendPushoverTwitchAlert.sh "'+mPushOver[0]+'" "'+mPushOver[1]+'" "'+s+'"'
        clipboard.setText(cmd)

        //lm.append(lm.add(from, msg))

        /*
        #!/bin/bash
        curl -s   --form-string "token=appPushovertoken"   --form-string "user=<userPushoverid>"   --form-string "message=$1"   https://api.pushover.net/1/messages.json
        */
        uqp.run(cmd)
    }
    function getUserIndex(user){
        let ret=-1
        let fd=u.getFile('./users')
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i].indexOf(user)===0){
                ret=i
                break
            }
        }
        return ret
    }
    function userIsEnabled(user){
        let ret=false
        let fd=u.getFile('./users')
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i].indexOf(user)>=0 && lines[i].indexOf(user+' true')>=0){
                ret=true
                break
            }
        }
        return ret
    }
    function toogleUserIsEnabled(user){
        let fd=u.getFile('./users')
        let lines=fd.split('\n')
        let s=''
        for(var i=0;i<lines.length;i++){
            if(lines[i].indexOf(user)>=0){
                if(lines[i].indexOf(user+' true')>=0){
                    s+=user+' false\n'
                }else{
                    s+=user+' true\n'
                }
            }else{
                s+=lines[i]+'\n'
            }
        }
        u.setFile('./users', s)
        updateUsersList()
    }
    function addUser(user){
        let fd=u.getFile('./users')
        let s=fd+'\n'+user+' false'
        s=s.replace(/\\n\\n/g, '')
        console.log('Agregando '+user+': \n'+s)
        u.setFile('./users', s)
        updateUsersList()
    }
    function deleteUser(user){
        let fd=u.getFile('./users')
        let s=''
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            let e=lines[i].indexOf(user)>=0
            if(!e){
                s+=lines[i]+'\n'
            }
        }
        u.setFile('./users', s)
        updateUsersList()
    }
    function updateUsersList(){
        lmUsers.clear()
        let fd=u.getFile('./users')
        let lines=fd.split('\n')
        for(var i=0;i<lines.length;i++){
            if(lines[i].length>=5)lmUsers.append(lmUsers.add(lines[i]))
        }
    }
}
