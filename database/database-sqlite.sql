

/*
- Bedragen in millicenten: het bedrag in euro's vermenigvuldigd met 100000. 
Dat is om afrondfouten te voorkomen: het datatype CURRENCY schijnt volgens fora niet 100% betrouwbaar te zijn.

- De datumtijd velden zijn in UTC: dus 1 uur vroeger dan CET.
Dat is omdat de default tijd alleen een standaard functie accepteert en niet iets als datetime(CURRENT_TIMESTAMP, 'localtime').
Triggers zou kunnen maar die zijn potentieel gevaarlijk of geven onbedoelde effecten.


Execute dit bestand: open een sqlite comand shell:
    D:\lazarus\externetools\sqlite\sqlite3.exe D:\projecten\wobbel\beurs_lazarus\database\wobbelbeurs.sp3
    SQLite version 3.7.3
    Enter ".help" for instructions
    Enter SQL statements terminated with a ";"
    sqlite>

Execute dit bestand: copy & paste in de sqlite3 command shell.
Of: 
    sqlite> .read D:/projecten/wobbel/beurs_lazarus/database/database-sqlite.sql



*/


DROP TRIGGER IF EXISTS update_naw_dtinvoeren;
DROP TRIGGER IF EXISTS update_naw_dtwijzigen;
DROP TRIGGER IF EXISTS update_artikel_dtinvoeren;
DROP TRIGGER IF EXISTS update_artikel_dtwijzigen;
DROP TRIGGER IF EXISTS update_beurs_klant_dtinvoeren;
DROP TRIGGER IF EXISTS update_beurs_klant_dtwijzigen;
DROP TRIGGER IF EXISTS update_beurs_verkoper_dtinvoeren;
DROP TRIGGER IF EXISTS update_beurs_verkoper_dtwijzigen;
DROP TRIGGER IF EXISTS update_beurs_vrijwilliger_dtinvoeren;
DROP TRIGGER IF EXISTS update_beurs_vrijwilliger_dtwijzigen;
DROP TRIGGER IF EXISTS update_kassaopensluit_dtsluit;
DROP TRIGGER IF EXISTS update_kassaopensluit_dtopen;
DROP TRIGGER IF EXISTS update_transactie_dtinvoeren;
DROP TRIGGER IF EXISTS update_transactie_dtwijzigen;
DROP TRIGGER IF EXISTS update_transactieartikel_dtinvoeren;
DROP TRIGGER IF EXISTS update_transactieartikel_dtwijzigen;
DROP TRIGGER IF EXISTS update_verkoper_externid;

DROP TABLE IF EXISTS "transactieartikel";
DROP TABLE IF EXISTS "transactie";
DROP TABLE IF EXISTS "kassaopensluit";
DROP TABLE IF EXISTS "kassa";
DROP TABLE IF EXISTS "kassabedrag";
DROP TABLE IF EXISTS "betaalwijze";
DROP TABLE IF EXISTS "beurs_vrijwilliger";
DROP TABLE IF EXISTS "beurs_verkoper";
DROP TABLE IF EXISTS "beurs_klant";
DROP TABLE IF EXISTS "beurs";
DROP TABLE IF EXISTS "vrijwilliger";
DROP TABLE IF EXISTS "verkoper";
DROP TABLE IF EXISTS "klant";
DROP TABLE IF EXISTS "artikel";
DROP TABLE IF EXISTS "artikeltype";
DROP TABLE IF EXISTS "naw";
DROP TABLE IF EXISTS "rol";




CREATE TABLE IF NOT EXISTS "rol"
(
"rol_id" INTEGER PRIMARY KEY AUTOINCREMENT,                 /* PK van tabel rol */
"omschrijving" VARCHAR(255) DEFAULT '',                           /* omschrijving */
"opmerkingen" VARCHAR(255) DEFAULT ''                           /* opmerkingen */
);



CREATE TABLE IF NOT EXISTS "naw"
(
"naw_id" INTEGER PRIMARY KEY AUTOINCREMENT,                      /* PK van tabel naw */
"hrmw" VARCHAR(10) DEFAULT '',                                   /* Heer / Mevrouw */
"voorletters" VARCHAR(20) DEFAULT '',                            /* voorletters */
"tussenvoegsel" VARCHAR(10) DEFAULT '',                          /* Tussenvoegsel */
"achternaam" VARCHAR(50) NOT NULL,                               /* Achternaam */
"straat" VARCHAR(100) NOT NULL,                                  /* Straat */
"huisnr" INTEGER NOT NULL,                                      /* Huisnummer */
"huisnrtoevoeging" VARCHAR(10) DEFAULT '',                       /* Huisnummertoevoeging */
"postcode" VARCHAR(20) DEFAULT '',                               /* Postcode */
"woonplaats" VARCHAR(100) NOT NULL,                              /* Woonplaats */
"telefoonmobiel1" VARCHAR(20) DEFAULT '',                        /* Telefoon mobiel 1 */
"telefoonmobiel2" VARCHAR(20) DEFAULT '',                        /* Telefoon mobiel 2 */
"telefoonvast" VARCHAR(20) DEFAULT '',                           /* Telefoon vast */
"email" VARCHAR(50) DEFAULT '',                                  /* email */
"datumtijdinvoeren" datetime DEFAULT CURRENT_TIMESTAMP,         /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime DEFAULT CURRENT_TIMESTAMP          /* datum en tijd van wijzigen */
);


CREATE TRIGGER IF NOT EXISTS update_naw_dtwijzigen AFTER UPDATE ON naw 
  BEGIN
    UPDATE naw SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE naw_id = new.naw_id;
  END;


-- insert into naw(achternaam,straat,huisnr,woonplaats) values('achternaam','straat',111,'woonplats');
-- select * from naw;
-- update naw set achternaam='blah' where naw_id=1;
-- select * from naw;


CREATE TABLE IF NOT EXISTS "artikeltype"
(
"artikeltype_id" NCHAR(2) PRIMARY KEY,                           /* PK van tabel artikeltype */
"omschrijving" VARCHAR(100) ,                                     /* omschrijving van het artikeltype */
"opmerkingen" VARCHAR(100)                                          /* opmerkingen bij het artikeltype */
);


CREATE TABLE IF NOT EXISTS "verkoper"
(
"verkoper_id" INTEGER PRIMARY KEY AUTOINCREMENT,                /* PK van tabel verkoper */
"nawid" INTEGER,                                                /* FK naar naw.naw_id */
"externid" VARCHAR(10) DEFAULT '' UNIQUE,                        /* extern id van de verkoper */
"saldobetalingcontant" BIT DEFAULT 1,                           /* uitbetaling contant (=1) of via rekening */
"rekeningnummer" VARCHAR(20) DEFAULT '',                         /* rekeningnr */
"rekeningopnaam" VARCHAR(50) DEFAULT '',                         /* rekeningnaam */
"rekeningbanknaam" VARCHAR(50) DEFAULT '',                       /* rekeningbanknaam */
"rekeningplaats" VARCHAR(100) DEFAULT '',                    	/* rekeningwoonplaats */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
FOREIGN KEY(nawid) REFERENCES naw(naw_id)
);

CREATE TRIGGER IF NOT EXISTS update_verkoper_externid AFTER INSERT ON verkoper 
  BEGIN
    UPDATE verkoper SET externid = new.verkoper_id WHERE verkoper_id = new.verkoper_id and externid='';
  END;


CREATE TABLE IF NOT EXISTS "artikel"
(
"artikel_id" INTEGER PRIMARY KEY AUTOINCREMENT,                  /* PK van tabel artikel */
"verkoperid" INTEGER,                                           /* FK naar verkoper.verkoper_id */
"code" VARCHAR(25),                                             /* code van het artikel */
-- "prijs" INTEGER,                                                /* prijs van het artikel,in Euro's x 100000. Millicenten dus */
"prijs" FLOAT DEFAULT 0.0,                                                /* prijs van het artikel,in Euro's */
"omschrijving" VARCHAR(100),                                     /* omschrijving van het artikel */
"artikeltypeid" NCHAR(2),                                       /* FK naar artikeltype.artikeltype_id */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(verkoperid) REFERENCES verkoper(verkoper_id),
FOREIGN KEY(artikeltypeid) REFERENCES artikeltype(artikeltype_id)
);



CREATE TRIGGER IF NOT EXISTS update_artikel_dtwijzigen AFTER UPDATE ON artikel 
  BEGIN
    UPDATE artikel SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE artikel_id = new.artikel_id;
  END;


CREATE TABLE IF NOT EXISTS "klant"
(
"klant_id" INTEGER PRIMARY KEY AUTOINCREMENT,                    /* PK van tabel Klant */
"opmerkingen" VARCHAR(255) DEFAULT ''                            /* opmerkingen */
);


CREATE TABLE IF NOT EXISTS "vrijwilliger"
(
"vrijwilliger_id" INTEGER PRIMARY KEY AUTOINCREMENT,             /* PK van tabel vrijwilliger */
"nawid" INTEGER NULL,                                                /* FK naar naw.naw_id. Mag NULL zijn */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
"inlognaam" VARCHAR(255) NOT NULL DEFAULT '',               /* inlognaam van de vrijwilliger */
"wachtwoord" VARCHAR(255) DEFAULT '',                           /* wachtwoord. Mag leeg zijn, behalve voor een admin account */
"rolid" INTEGER,                                                /* FK naar rol.rol_id */
FOREIGN KEY(nawid) REFERENCES naw(naw_id),
FOREIGN KEY(rolid) REFERENCES rol(rol_id)
);


CREATE TABLE IF NOT EXISTS "beurs"
(
"beurs_id" INTEGER PRIMARY KEY AUTOINCREMENT,                    /* PK van tabel beurs */
"datum" VARCHAR(25) NULL,                                              /* datum van de beurs */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
-- "opbrengst" INTEGER DEFAULT 0                                   /* opbrengst van de beurs,in Euro's x 100000. Millicenten dus  */
"opbrengst" FLOAT DEFAULT 0.0,                                   /* opbrengst van de beurs,in Euro's  */
"isactief" INTEGER DEFAULT 0                                   /* 1 als het record de huidige beurs is, anders 0  */
);

CREATE TABLE IF NOT EXISTS "beurs_klant"
(
"beurs_klant_id" INTEGER PRIMARY KEY AUTOINCREMENT,              /* PK van tabel beurs_klant */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"klantid" INTEGER NOT NULL,                                     /* FK naar tabel klant */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(beursid) REFERENCES beurs(beurs_id),
FOREIGN KEY(klantid) REFERENCES klant(klant_id)
);

CREATE TRIGGER IF NOT EXISTS update_beurs_klant_dtwijzigen AFTER UPDATE ON beurs_klant 
  BEGIN
    UPDATE beurs_klant SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_klant_id = new.beurs_klant_id;
  END;


CREATE TABLE IF NOT EXISTS "beurs_verkoper"
(
"beurs_verkoper_id" INTEGER PRIMARY KEY AUTOINCREMENT,           /* PK van tabel beurs_verkoper */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"verkoperid" INTEGER NOT NULL,                                  /* FK naar tabel verkoper */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(beursid) REFERENCES beurs(beurs_id),
FOREIGN KEY(verkoperid) REFERENCES verkoper(verkoper_id)
);

CREATE TRIGGER IF NOT EXISTS update_beurs_verkoper_dtwijzigen AFTER UPDATE ON beurs_verkoper 
  BEGIN
    UPDATE beurs_verkoper SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_verkoper_id = new.beurs_verkoper_id;
  END;


CREATE TABLE IF NOT EXISTS "beurs_vrijwilliger"
(
"beurs_vrijwilliger_id" INTEGER PRIMARY KEY AUTOINCREMENT,       /* PK van tabel beurs_vrijwilliger */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"vrijwilligerid" INTEGER NOT NULL,                              /* FK naar tabel vrijwilliger */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(beursid) REFERENCES beurs(beurs_id),
FOREIGN KEY(vrijwilligerid) REFERENCES vrijwilliger(vrijwilliger_id)
);

CREATE TRIGGER IF NOT EXISTS update_beurs_vrijwilliger_dtwijzigen AFTER UPDATE ON beurs_vrijwilliger 
  BEGIN
    UPDATE beurs_vrijwilliger SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_vrijwilliger_id = new.beurs_vrijwilliger_id;
  END;


CREATE TABLE IF NOT EXISTS "betaalwijze"
(
"betaalwijze_id" INTEGER PRIMARY KEY NOT NULL,                            /* PK van tabel betaalwijze */
"omschrijving" VARCHAR(100),                                       /* omschrijving van de betaalwijze */
"opmerkingen" VARCHAR(100)                                           /* opmerkingen bij de betaalwijze */
);


CREATE TABLE IF NOT EXISTS "kassabedrag"
(
"kassabedrag_id" INTEGER PRIMARY KEY AUTOINCREMENT,              /* PK van tabel kassabedrag */
"biljet_500" INTEGER DEFAULT 0,                                 /* aantal biljetten van 500 euro */
"biljet_200" INTEGER DEFAULT 0,                                 /* aantal biljetten van 200 euro */
"biljet_100" INTEGER DEFAULT 0,                                 /* aantal biljetten van 100 euro */
"biljet_50" INTEGER DEFAULT 0,                                  /* aantal biljetten van 50 euro */
"biljet_20" INTEGER DEFAULT 0,                                  /* aantal biljetten van 20 euro */
"biljet_10" INTEGER DEFAULT 0,                                  /* aantal biljetten van 10 euro */
"biljet_5" INTEGER DEFAULT 0,                                   /* aantal biljetten van 5 euro */
"munt_2" INTEGER DEFAULT 0,                                     /* aantal munten van 2 euro */
"munt_1" INTEGER DEFAULT 0,                                     /* aantal munten van 1 euro */
"munt_0,50" INTEGER DEFAULT 0,                                  /* aantal munten van 50 eurocent */
"munt_0,20" INTEGER DEFAULT 0,                                  /* aantal munten van 20 eurocent */
"munt_0,10" INTEGER DEFAULT 0,                                  /* aantal munten van 10 eurocent */
"munt_0,05" INTEGER DEFAULT 0,                                  /* aantal munten van 5 eurocent */
"munt_0,02" INTEGER DEFAULT 0,                                  /* aantal munten van 2 eurocent */
"munt_0,01" INTEGER DEFAULT 0,                                   /* aantal munten van 1 eurocent */ 
"opmerkingen" VARCHAR(255) DEFAULT ''                           /* opmerkingen */
);

-- delete from kassabedrag where kassabedrag_id=1;
-- select * from kassabedrag
-- insert into kassabedrag (biljet_500, biljet_200, biljet_100, biljet_50, biljet_20, biljet_10, biljet_5, munt_2, munt_1, "munt_0,50", "munt_0,20", "munt_0,10", "munt_0,05", "munt_0,02", "munt_0,01") values (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
-- insert into kassabedrag (biljet_500, biljet_200, biljet_100) values (1,2,3);
-- select "biljet_500"*500.0 + "biljet_200"*200.0 + "biljet_100"*100.0 + "biljet_50"*50.0 + "biljet_20"*20.0 + "biljet_10"*10.0 + "biljet_5"*5.0 + "munt_2"*2.0 + "munt_1"*1.0 + "munt_0,50"*0.5 + "munt_0,20"*0.2 + "munt_0,10"*0.1 + "munt_0,05" * 0.05 + "munt_0,02"*0.02 + "munt_0,01"*0.01 from kassabedrag;



CREATE TABLE IF NOT EXISTS "kassa"
(
"kassa_id" INTEGER PRIMARY KEY AUTOINCREMENT,                              /* PK van tabel kassa, d ekassacode toegekend bij installeren */
"kassaid_bij_integratie" INTEGER NULL,                      /* code van de kassa. Eventueel veranderd bij integratie als blijkt dat de kassa_id al bestaat */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"kassanr" VARCHAR(20) DEFAULT '' NOT NULL,                        /* identificatie van de kassa; uniek per beurs */
"isactief" INTEGER DEFAULT 0,                                   /* 1 als het record de voor deze installatie actieve kassa is, anders 0  */
"opmerkingen" VARCHAR(255) DEFAULT ''                            /* opmerkingen */
);



CREATE TABLE IF NOT EXISTS "kassaopensluit"
(
"kassaopensluit_id" INTEGER PRIMARY KEY AUTOINCREMENT,           /* PK van tabel kassaopensluit */
"kassabedragid_open" INTEGER DEFAULT 0,                          /* FK naar openbedrag van de kassa */
"datumtijdopen" datetime NULL DEFAULT CURRENT_TIMESTAMP,        /* datum en tijd van openen van kassa */
"kassabedragid_sluit" INTEGER DEFAULT 0,                         /* FK naar sluitbedrag van de kassa */
"datumtijdsluit" datetime NULL DEFAULT CURRENT_TIMESTAMP,       /* datum en tijd van sluiten van kassa */
"kassaid" INTEGER NOT NULL,                                     /* FK naar tabel kassa */
FOREIGN KEY(kassabedragid_open) REFERENCES kassabedrag(kassabedrag_id),
FOREIGN KEY(kassabedragid_sluit) REFERENCES kassabedrag(kassabedrag_id),
FOREIGN KEY(kassaid) REFERENCES kassa(kassa_id)
);


CREATE TRIGGER IF NOT EXISTS update_kassaopensluit_dtsluit AFTER UPDATE ON kassaopensluit 
  BEGIN
    UPDATE kassaopensluit SET datumtijdsluit = CURRENT_TIMESTAMP WHERE kassaopensluit_id = new.kassaopensluit_id;
  END;


CREATE  TABLE "transactie"
(
"transactie_id" INTEGER PRIMARY KEY AUTOINCREMENT,               /* PK van tabel transactie */
"klantid" INTEGER NOT NULL,                                     /* FK naar tabel klant */
"kassaid" INTEGER NOT NULL,                                     /* FK naar tabel kassa */
"vrijwilligerid" INTEGER NULL,                              /* FK naar tabel vrijwilliger: degene die ingelogd is en de transactie invoert */
"betaalwijzeid" INTEGER NOT NULL,                               /* FK naar tabel betaalwijze */
-- "totaalbedrag" INTEGER DEFAULT 0,                               /* totaalbedrag van de transactie,in Euro's x 100000. Millicenten dus  */
"totaalbedrag" FLOAT DEFAULT 0.0,                               /* totaalbedrag van de transactie,in Euro's */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
FOREIGN KEY(klantid) REFERENCES klant(klant_id),
FOREIGN KEY(kassaid) REFERENCES kassa(kassa_id),
FOREIGN KEY(betaalwijzeid) REFERENCES betaalwijze(betaalwijze_id)
);


CREATE TRIGGER IF NOT EXISTS update_transactie_dtwijzigen AFTER UPDATE ON transactie 
  BEGIN
    UPDATE transactie SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE transactie_id = new.transactie_id;
  END;



CREATE  TABLE "transactieartikel"
(
"transactieartikel_id" INTEGER PRIMARY KEY AUTOINCREMENT,        /* PK van tabel transactieartikel */
"transactieid" INTEGER,                                         /* ID van de transactie. FK naar transactie.transactie_id */
"artikelid" INTEGER,                                            /* ID van het artikel. FK naar artikel.artikel_id */
"volgnr" INTEGER DEFAULT 0,                                     /* volgnr van het artikel binnen de transactie */
"kortingsfactor" FLOAT DEFAULT 1.0,                             /* eventuele korting op het artikel uitgedrukt als factor. factor 1.0 = geen korting, factor 0.5 = 50% korting */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(transactieid) REFERENCES transactie(transactie_id),
FOREIGN KEY(artikelid) REFERENCES artikel(artikel_id)
);


CREATE TRIGGER IF NOT EXISTS update_transactieartikel_dtwijzigen AFTER UPDATE ON transactieartikel 
  BEGIN
    UPDATE transactieartikel SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE transactieartikel_id = new.transactieartikel_id;
  END;



-- invullen testdata
insert into rol (rol_id, omschrijving, opmerkingen) values (1,'kassa', 'transacties invoeren');
insert into rol (rol_id, omschrijving, opmerkingen) values (2,'beheerder', 'applicatie beheren');

insert into betaalwijze (betaalwijze_id, omschrijving, opmerkingen) values (1,'contant', 'contante betaling');
insert into betaalwijze (betaalwijze_id, omschrijving, opmerkingen) values (2,'pin', 'betaling met pin');
insert into betaalwijze (betaalwijze_id, omschrijving, opmerkingen) values (3,'creditcard', 'betaling met creditcard');

insert into artikeltype (artikeltype_id, omschrijving, opmerkingen) values ('nv','ongedefinieerd', 'standaard');
insert into artikeltype (artikeltype_id, omschrijving, opmerkingen) values ('sp','speelgoed', 'voor speelgoed');
insert into artikeltype (artikeltype_id, omschrijving, opmerkingen) values ('bk','boek', 'voor boeken');
insert into artikeltype (artikeltype_id, omschrijving, opmerkingen) values ('kl','kleding', 'voor kleding');

insert into verkoper(verkoper_id,nawid,opmerkingen) values (0,0,'blah');


insert into beurs (datum,opmerkingen,opbrengst,isactief) values ('20110306','eerste beurs van 2011',12345.23,0);
insert into beurs (datum,opmerkingen,opbrengst,isactief) values ('20110816','tweede beurs van 2011',11223.0,0);
insert into beurs (datum,opmerkingen,opbrengst,isactief) values ('20120311','eerste beurs van 2012',11233.0,0);
insert into beurs (datum,opmerkingen,opbrengst,isactief) values ('20121130','tweede beurs van 2012',10022.0,1);



insert into vrijwilliger (inlognaam,wachtwoord, rolid) values('beheerder', 'wwbeheerder', (select rol_id from rol where omschrijving='beheerder'));
insert into vrijwilliger (inlognaam,wachtwoord, rolid) values('kassa1', '', (select rol_id from rol where omschrijving='kassa'));
insert into vrijwilliger (inlognaam,wachtwoord, rolid) values('kassa2', '', (select rol_id from rol where omschrijving='kassa'));
insert into vrijwilliger (inlognaam,wachtwoord, rolid) values('kassa3', '', (select rol_id from rol where omschrijving='kassa'));
-- select * from vrijwilliger as v left join rol as r on v.rolid = r.rol_id;
-- select v.vrijwilliger_id, v.inlognaam, v.wachtwoord, v.opmerkingen as vopmerkingen, v.nawid, v.rolid, r.rol_id, r.omschrijving, r.opmerkingen as ropmerkingen from vrijwilliger as v left join rol as r on v.rolid = r.rol_id



insert into naw(hrmw,voorletters,tussenvoegsel,achternaam,straat,huisnr,huisnrtoevoeging,postcode,woonplaats,telefoonmobiel1,telefoonmobiel2,telefoonvast,email) values (
'Dhr.','A.B.C.','van der','Accchternaam','Straatweg',123,'bis','1234AB','Lutjebroek','0612345678','0623456789','0123456789','aaa1@bbbb.nl');
insert into verkoper(nawid,saldobetalingcontant,rekeningnummer,rekeningopnaam,rekeningbanknaam,rekeningplaats,opmerkingen) values (
(select max(naw_id) from naw),0,'P00012345','rekeningnaamhouder','RAbobank','Amersfoort','fodsfsf');
insert into beurs_verkoper(beursid,verkoperid) values ((select beurs_id from beurs where isactief=1), (select max(verkoper_id) from verkoper));

insert into naw(hrmw,voorletters,tussenvoegsel,achternaam,straat,huisnr,huisnrtoevoeging,postcode,woonplaats,telefoonmobiel1,telefoonmobiel2,telefoonvast,email) values (
'Mw.','A.','de','Blaat','Kerkweg',3,'','1111AB','Lutjebroek','0612345678','0623456789','0123456789','aaa2@bbbb.nl');
insert into verkoper(nawid,saldobetalingcontant,rekeningnummer,rekeningopnaam,rekeningbanknaam,rekeningplaats,opmerkingen) values (
(select max(naw_id) from naw),0,'1112233','Blaat','AMRObank','Amersfoort','opmerkingen2');
insert into beurs_verkoper(beursid,verkoperid) values ((select beurs_id from beurs where isactief=1), (select max(verkoper_id) from verkoper));

insert into naw(hrmw,voorletters,tussenvoegsel,achternaam,straat,huisnr,huisnrtoevoeging,postcode,woonplaats,telefoonmobiel1,telefoonmobiel2,telefoonvast,email) values (
'','X.','','Verkoper','Straateg',13,'','0012AB','MAsterdam','0612345678','0623456789','0123456789','aaa3@bbbb.nl');
insert into verkoper(nawid,saldobetalingcontant,rekeningnummer,rekeningopnaam,rekeningbanknaam,rekeningplaats,opmerkingen) values (
(select max(naw_id) from naw),0,'33445566','Verkoper','Rabobank','Amersfoort','opmerkingen2');
insert into beurs_verkoper(beursid,verkoperid) values ((select beurs_id from beurs where isactief=1), (select max(verkoper_id) from verkoper));




--------------------------
/*
insert into verkoper("naam","straat","huisnummer","huisnummertoevoeging","postcode","plaats") values ('Pietje Puk','Straatweg',22,'b','1234AB','''s Hertogenbosch');
insert into verkoper("naam","straat","huisnummer","huisnummertoevoeging","postcode","plaats") values ('Donald Duck','stripweg',543,'','2345CD','Moddergat');
insert into verkoper("naam","straat","huisnummer","huisnummertoevoeging","postcode","plaats") values ('Guust Flater','Hoofdstraat',11,'bis','3456EF','Broek op Waterland');

insert into artikel("code","IDverkoper","naam","omschrijving","prijs") values ('Guust Flater','Hoofdstraat',11,'bis','3456EF','Broek op Waterland');
*/


