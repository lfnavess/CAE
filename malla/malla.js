//Custom protoypes
if(!String.prototype.replaceAll){ 
    //http://stackoverflow.com/questions/1144783/replacing-all-occurrences-of-a-string-in-javascript
    String.prototype.replaceAll = function (find, replace) {
        return this.replace(new RegExp(find, 'g'), replace);
    };
}
if(!String.prototype.trimSingleLine){
    //http://stackoverflow.com/questions/498970/how-do-i-trim-a-string-in-javascript
    String.prototype.trimSingleLine = function () {
        return this.replace(/^\s+|\s+$/g, '').replace(/\s+/g, ' ');
    };
}
if(!String.prototype.accentFold){
    //https://stackoverflow.com/questions/5700636/using-javascript-to-perform-text-matches-with-without-accented-characters
     String.prototype.accentFold = function () {
        return this.replace(
            /([àáâãäåāăąǎǟǡǻȁȃȧⱥɐḁẚạảấầẩẫậắằẳẵặɑɒ])|([ƀɓƃʙḃḅḇ])|([çćĉċčƈȼɕʗ])|([ďđɖɗƌȡḋḍḏḑḓ])|([èéêëēĕėęěǝȅȇȩɇɛɜɝɞḕḗḙḛẹẻẽếềểễệɘʚ])|([ƒḟ])|([ĝğġģɠǥǧǵɡɢʛḡɣɤ])|([ĥħȟɥɦʜḣḥḧḩḫẖ])|([ìíîïĩīĭįıǐȉȋɨɪḭḯỉị])|([ĵǰȷɉɟʄʝ])|([ķƙǩʞḱḳḵ])|([ĺļľŀłƚȴɫɬɭʟḷḹḻḽ])|([ɯɰɱḿṁṃ])|([ñńņňŉƞǹȵɲɳṅṇṉṋ])|([òóôõöøōŏőơǒǫǭǿȍȏȫȭȯȱɔɵṍṏṑṓọỏốồổỗộớờởỡợωɷ])|([ƥʠṕṗ])|([ɋ])|([ŕŗřȑȓɍɹɺɻɼɽɾɿʀʁṙṛṝṟ])|([ßśŝşšſșȿʂṡṣṥṧṩẛ])|([ţťŧƫƭʈțȶⱦʇṫṭṯṱẗ])|([ùúûüũūŭůűųưǔǖǘǚǜȕȗʉṳṵṷṹṻụủứừửữự])|([ʋʌṽṿ])|([ŵʍẁẃẅẇẉẘ])|([ẋẍ])|([ýÿŷƴȳɏʎʸʏẏẙỳỵỷỹ])|([źżžƶȥɀʐʑẑẓẕ])|([æǣǽ])|([ĳ])/gi, 
            function(str,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,ae,ij) {
                var tmp = a?"a":b?"b":c?"c":d?"d":e?"e":f?"f":g?"g":h?"h":i?"i":j?"j":k?"k":l?"l":m?"m":n?"n":o?"o":p?"p":q?"q":r?"r":s?"s":t?"t":u?"u":v?"v":w?"w":x?"x":y?"y":z?"z":ae?"ae":ij?"ij":"";
                return str === str.toUpperCase() ? tmp.toUpperCase() : tmp;
            }
        );
    }
}
if(!String.prototype.removeDuplicated){
    String.prototype.removeDuplicated = function (){
        return this.replace(
            /(a{2,})|(b{2,})|(c{2,})|(d{2,})|(e{2,})|(f{2,})|(g{2,})|(h{2,})|(i{2,})|(j{2,})|(k{2,})|(l{2,})|(m{2,})|(n{2,})|(o{2,})|(p{2,})|(q{2,})|(r{2,})|(s{2,})|(t{2,})|(u{2,})|(v{2,})|(w{2,})|(x{2,})|(y{2,})|(z{2,})/gi,
            function(str){ return str[0]; }
        );
    }
}
if(!String.prototype.format) {
    //http://stackoverflow.com/questions/18405736/is-there-a-c-sharp-string-format-equivalent-in-javascript
    String.prototype.format = function() {
        'use strict';
        var args = arguments;
        return this.replace(/{(\d+)}/g, function(match, number) { return typeof args[number] !== undefined ? args[number] : match; });
    };
} 


function clean(str){ if(!str){ return null; } str = str.trimSingleLine().accentFold().toUpperCase();  return str ? str : null; }
var API_CAE = (function(){
    'use strict';
    return {
        searchUser: function(username, callback){
            username = clean(username);
            var searchby = username.indexOf("@") > -1 ? "email" : isNaN(username) ? "idcard" : "username";
            get("/api/v1/users", "GET", [["searchby", searchby], ["search", username]], undefined, function(r){
                if(r){ r = r.results; }
                if(r){ r = r.find(function(u){ return clean(u[searchby]) === username; }); }
                callback(r);
            });
        },
        searchCourse: function(name, callback){
            name = clean(name);
            get("/api/v1/courses", "GET", [["searchby", "name"], ["search", name], ["visible", "false"]], undefined, function(r){
                if(r){ r = r.results; }
                if(r){ r = r.find(function(c){ return clean(c.name) === name; }); }
                callback(r);
            });
        },
        searchGroup: function(courseid, name, callback){
            name = clean(name);
            get("/api/v1/courses/{0}/groups".format(courseid), "GET", [["search", name]], undefined, function(r){
                if(r){ r = r.results; }
                if(r){ r = r.find(function(g){ return clean(g.name) === name; }); }
                callback(r);
            });
        },
        createGroup: function(courseid, name, callback){
            name = clean(name);
            get("/api/v1/courses/{0}/groups".format(courseid), "POST", undefined, { "name": name }, callback);
        },
        searchEnrollment: function (courseid, groupid, user, callback){
            get("/api/v1/courses/{0}/groups/{1}/enrollments".format(courseid, groupid), "GET", [["search", user.username], ["filter", "all"]], undefined, function(r){
                if(r){ r = r.results; }
                if(r){ r = r.find(function(e){ return e.user.id === user.id; }); }
                callback(r);
            });
        },
        createEnrollment: function (courseid, groupid, user, enddate, callback){
            if(!enddate){ enddate = moment().add(1, "months"); }
            if(enddate.day() === 0){ enddate.add(1, "days"); }
            else if(enddate.day() === 6){ enddate.add(2, "days"); }
            get("/api/v1/courses/{0}/groups/{1}/enrollments".format(courseid, groupid), "POST", undefined, {
                "userid":user.id,"accessmode":"online","sequential":"true","startdate":moment().format("YYYY-MM-DD"),"enddate":enddate.format("YYYY-MM-DD")
            }, callback);
        },
        gotoEnrollment: function (username, enrollmentid, activityid){
            var parameters = [["siteid", 5],["username", username],["password", "e6286deb52a3f08f4887543e0fe12344"],["enrolment", enrollmentid]];
            if(activityid){ parameters.push(["redirectto", "activity"]); parameters.push(["activity", activityid]); }
            window.location.href = uri(API_CAE.host, "/default/LoginBridge.rails", parameters);
            //window.location.replace(uri);
        },
        getEnrollments: function(user, groupname, callback){
            groupname = clean(groupname);
            get("/api/v1/enrollments", "GET", [
                ["limit", 50], ["searchby", "username"], ["search", user.username], ["orderby", "startdate"], ["asc", 0], ["filter", "all"]
            ], undefined, function(r){
                if(r){ r = r.results; }
                if(r){ r = r.find(function(e){ return e.user.id === user.id && clean(e.group.name) === groupname && e.percentage < 100; }); }
                callback(r);
            });
        }
    }
    function get(path, method, query, post, callback){
        //https://github.com/matthew-andrews/isomorphic-fetch/issues/48
        var date =  moment.utc().format("DDMMYYYYHH:mm:ss");
        var digest = new jsSHA("SHA-256", "TEXT");
        digest.setHMACKey(API_CAE.password, "TEXT");
        digest.update("{0}+{1}+{2}".format(method, path, date));
        fetch(uri(API_CAE.host, path, query), {cache: "no-store", mode: "cors", method: method, headers: {
            'Content-Type': "application/json", 'Accept': "application/json", 'Authorization': "hmac {0}:{1}".format(API_CAE.username, digest.getHMAC("B64")),
            'RequestDate': date
        }, body: JSON.stringify(post)})
        .then(function(response) { if(!response.ok){ callback(); } return response.json(); })
        .then(function(data){ callback(data); });
    }
    function uri(host, path, query){
        return encodeURI("{0}{1}{2}".format(host, path, query ? "?{0}".format(query.map(function(param){ return param.join("="); }).join("&")) : ""));
    }
})();
        
function enroll(username, coursename, btn, prog, callback){
    'use strict';
    username = clean(username);
    coursename = clean(coursename);
    if(!callback){ callback = function(enrollment){  if(enrollment){ API_CAE.gotoEnrollment(user.username, enrollment.id); } }; }
    if(!username){ showAlert("Usaurio requerido"); callback(); return; }
    if(!coursename){ showAlert("Curso requerido"); callback(); return; }
    if(!btn){ btn = { disabled: "" };  }
    if(!prog){ prog = { value: "" };  }
    prog.value = 0;
    btn.disabled = true;
    var groupname = "Online, Malla|s002866";
    API_CAE.searchUser(username, function (user){
        ++prog.value;
        if(!user){ showAlert("Usuario no encontrado"); callback(); return; }
        API_CAE.searchCourse(coursename, function(course){
            ++prog.value;
            if(!course){ showAlert("Curso no encontrado"); callback(); return; }
            API_CAE.searchGroup(course.id, groupname, function(group){
                ++prog.value;
                if(!group){ API_CAE.createGroup(course.id, groupname, groupready); } else{ groupready(group); }
            });
            function groupready(group){
                ++prog.value;
                if(!group){ showAlert("No se pudo crear el grupo"); callback(); return; }
                API_CAE.searchEnrollment(course.id, group.id, user, function (enrollment){
                    ++prog.value;
                    if(!enrollment){
                        API_CAE.getEnrollments(user, groupname, function(enrollment){
                            ++prog.value;
                            if(enrollment){ showAlert("Tienes inscrito el curso {0}, para inscribirte a otro debes completarlo.".format(enrollment.course.name)); callback(false); return; }
                            API_CAE.createEnrollment(course.id, group.id, user, moment("2017-12-31"), enrollmentready);
                        });
                    }else{ ++prog.value; enrollmentready(enrollment); }
                });
            }
        });
        function enrollmentready(enrollment){
            ++prog.value;
            if(!enrollment){ showAlert("No se pudo crear la inscripción"); callback(); return; }
            callback(enrollment, user);
        }
    });
    function showAlert(message){
        alert(message + "\ncomunicate a Red Educativa:\n    (+52 55) 1669-3455 ext. 3455\n    rededucativa@ppg.com");
        btn.disabled = false;
        prog.value = 0;
    }
}