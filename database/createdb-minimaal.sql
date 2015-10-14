PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE "rol"
(
"rol_id" INTEGER PRIMARY KEY AUTOINCREMENT,                 /* PK van tabel rol */
"omschrijving" VARCHAR(255) DEFAULT '',                           /* omschrijving */
"opmerkingen" VARCHAR(255) DEFAULT ''                           /* opmerkingen */
);


CREATE TABLE "artikeltype"
(
"artikeltype_id" NCHAR(2) PRIMARY KEY,                           /* PK van tabel artikeltype */
"omschrijving" VARCHAR(100) ,                                     /* omschrijving van het artikeltype */
"opmerkingen" VARCHAR(255) DEFAULT ''                                          /* opmerkingen bij het artikeltype */
);


CREATE TABLE "betaalwijze"
(
"betaalwijze_id" INTEGER PRIMARY KEY NOT NULL,                            /* PK van tabel betaalwijze */
"omschrijving" VARCHAR(100),                                       /* omschrijving van de betaalwijze */
"opmerkingen" VARCHAR(255)  DEFAULT ''                                           /* opmerkingen bij de betaalwijze */
);


CREATE TABLE "kassastatus"
(
"kassastatus_id" INTEGER PRIMARY KEY AUTOINCREMENT,           /* PK van tabel kassastatus */
"status" VARCHAR(20) DEFAULT '' NOT NULL                      /* statuswaarde */
);


CREATE TABLE "beurs"
(
"beurs_id" INTEGER PRIMARY KEY AUTOINCREMENT,                    /* PK van tabel beurs */
"datum" VARCHAR(25) NULL,                                              /* datum van de beurs */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
"opbrengst" FLOAT DEFAULT 0.0,                                   /* opbrengst van de beurs,in Euro's  */
"isactief" INTEGER DEFAULT 0,                                   /* 1 als het record de huidige beurs is, anders 0  */
"datumtijdinvoeren" datetime DEFAULT CURRENT_TIMESTAMP,         /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime DEFAULT CURRENT_TIMESTAMP          /* datum en tijd van wijzigen */
);



CREATE TABLE "kassabedrag"
(
"kassabedrag_id" INTEGER PRIMARY KEY AUTOINCREMENT,              /* PK van tabel kassabedrag */
"totaalbedrag" FLOAT DEFAULT 0.0,                               /* totaalbedrag van de kassa,in Euro's */
"opmerkingen" VARCHAR(255) DEFAULT ''                           /* opmerkingen */
);


CREATE TABLE "kassaopensluit"
(
"kassaopensluit_id" INTEGER PRIMARY KEY AUTOINCREMENT,           /* PK van tabel kassaopensluit */
"kassabedragid" INTEGER DEFAULT 0,                          /* FK naar openbedrag van de kassa */
"datumtijd" datetime NULL DEFAULT CURRENT_TIMESTAMP,        /* datum en tijd van invoeren record */
"kassastatusid" INTEGER DEFAULT 0,                         /* FK naar kassastatus */
"kassaid" INTEGER NOT NULL,                                     /* FK naar tabel kassa */
FOREIGN KEY(kassabedragid) REFERENCES kassabedrag(kassabedrag_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(kassastatusid) REFERENCES kassastatus(kassastatus_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(kassaid) REFERENCES kassa(kassa_id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE "kassa"
(
"kassa_id" INTEGER PRIMARY KEY AUTOINCREMENT,                              /* PK van tabel kassa, d ekassacode toegekend bij installeren */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"kassanr" VARCHAR(50) DEFAULT '' NOT NULL,                        /* identificatie van de kassa; uniek per beurs */
"isactief" INTEGER DEFAULT 0,                                   /* 1 als het record de voor deze installatie actieve kassa is, anders 0  */
"opmerkingen" VARCHAR(255) DEFAULT '',                            /* opmerkingen */
"datumtijdinvoeren" datetime DEFAULT CURRENT_TIMESTAMP,         /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime DEFAULT CURRENT_TIMESTAMP          /* datum en tijd van wijzigen */
);

CREATE TABLE "naw"
(
"naw_id" INTEGER PRIMARY KEY AUTOINCREMENT,                      /* PK van tabel naw */
"aanhef" VARCHAR(10) DEFAULT '',                                   /* Heer / Mevrouw */
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


CREATE TABLE "vrijwilliger"
(
"vrijwilliger_id" INTEGER PRIMARY KEY AUTOINCREMENT,             /* PK van tabel vrijwilliger */
"nawid" INTEGER NULL,                                                /* FK naar naw.naw_id. Mag NULL zijn */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
"inlognaam" VARCHAR(255) NOT NULL DEFAULT '',               /* inlognaam van de vrijwilliger */
"wachtwoord" VARCHAR(255) DEFAULT '',                           /* wachtwoord. Mag leeg zijn, behalve voor een admin account */
"rolid" INTEGER,                                                /* FK naar rol.rol_id */
FOREIGN KEY(nawid) REFERENCES naw(naw_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(rolid) REFERENCES rol(rol_id) DEFERRABLE INITIALLY DEFERRED
);


CREATE TABLE "beurs_vrijwilliger"
(
"beurs_vrijwilliger_id" INTEGER PRIMARY KEY AUTOINCREMENT,       /* PK van tabel beurs_vrijwilliger */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"vrijwilligerid" INTEGER NOT NULL,                              /* FK naar tabel vrijwilliger */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(beursid) REFERENCES beurs(beurs_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(vrijwilligerid) REFERENCES vrijwilliger(vrijwilliger_id) DEFERRABLE INITIALLY DEFERRED
);



CREATE TABLE "verkoper"
(
"verkoper_id" INTEGER PRIMARY KEY AUTOINCREMENT,                /* PK van tabel verkoper */
"nawid" INTEGER,                                                /* FK naar naw.naw_id */
"verkopercode" VARCHAR(50) DEFAULT '' UNIQUE,                        /* extern id van de verkoper */
"saldobetalingcontant" BIT DEFAULT 1,                           /* uitbetaling contant (=1) of via rekening */
"rekeningnummer" VARCHAR(20) DEFAULT '',                         /* rekeningnr */
"rekeningopnaam" VARCHAR(50) DEFAULT '',                         /* rekeningnaam */
"rekeningbanknaam" VARCHAR(50) DEFAULT '',                       /* rekeningbanknaam */
"rekeningplaats" VARCHAR(100) DEFAULT '',                        /* rekeningwoonplaats */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
FOREIGN KEY(nawid) REFERENCES naw(naw_id) DEFERRABLE INITIALLY DEFERRED
);


CREATE TABLE "beurs_verkoper"
(
"beurs_verkoper_id" INTEGER PRIMARY KEY AUTOINCREMENT,           /* PK van tabel beurs_verkoper */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"verkoperid" INTEGER NOT NULL,                                  /* FK naar tabel verkoper */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(beursid) REFERENCES beurs(beurs_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(verkoperid) REFERENCES verkoper(verkoper_id) DEFERRABLE INITIALLY DEFERRED
);



CREATE TABLE "klant"
(
"klant_id" INTEGER PRIMARY KEY AUTOINCREMENT,                    /* PK van tabel Klant */
"opmerkingen" VARCHAR(255) DEFAULT ''                            /* opmerkingen */
);


CREATE TABLE "beurs_klant"
(
"beurs_klant_id" INTEGER PRIMARY KEY AUTOINCREMENT,              /* PK van tabel beurs_klant */
"beursid" INTEGER NOT NULL,                                     /* FK naar tabel beurs */
"klantid" INTEGER NOT NULL,                                     /* FK naar tabel klant */
"opmerkingen" VARCHAR(255) DEFAULT '',                           /* opmerkingen */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(beursid) REFERENCES beurs(beurs_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(klantid) REFERENCES klant(klant_id) DEFERRABLE INITIALLY DEFERRED
);


CREATE TABLE "artikel"
(
"artikel_id" INTEGER PRIMARY KEY AUTOINCREMENT,                  /* PK van tabel artikel */
"verkoperid" INTEGER,                                           /* FK naar verkoper.verkoper_id */
"code" VARCHAR(25),                                             /* code van het artikel */
"prijs" FLOAT DEFAULT 0.0,                                                /* prijs van het artikel,in Euro's */
"omschrijving" VARCHAR(100),                                     /* omschrijving van het artikel */
"opmerkingen" VARCHAR(255)  DEFAULT '',                                          /* opmerkingen */
"artikeltypeid" NCHAR(2),                                       /* FK naar artikeltype.artikeltype_id */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(verkoperid) REFERENCES verkoper(verkoper_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(artikeltypeid) REFERENCES artikeltype(artikeltype_id) DEFERRABLE INITIALLY DEFERRED
);



CREATE TABLE "transactie"
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
FOREIGN KEY(klantid) REFERENCES klant(klant_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(kassaid) REFERENCES kassa(kassa_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(betaalwijzeid) REFERENCES betaalwijze(betaalwijze_id) DEFERRABLE INITIALLY DEFERRED
);


CREATE TABLE "transactieartikel"
(
"transactieartikel_id" INTEGER PRIMARY KEY AUTOINCREMENT,        /* PK van tabel transactieartikel */
"transactieid" INTEGER,                                         /* ID van de transactie. FK naar transactie.transactie_id */
"artikelid" INTEGER,                                            /* ID van het artikel. FK naar artikel.artikel_id */
"volgnr" INTEGER DEFAULT 0,                                     /* volgnr van het artikel binnen de transactie */
"kortingsfactor" FLOAT DEFAULT 1.0,                             /* eventuele korting op het artikel uitgedrukt als factor. factor 1.0 = geen korting,factor 0.5 = 50% korting */
"datumtijdinvoer" datetime NULL DEFAULT CURRENT_TIMESTAMP,      /* datum en tijd van invoeren */
"datumtijdwijzigen" datetime NULL DEFAULT CURRENT_TIMESTAMP,    /* datum en tijd van wijzigen */
FOREIGN KEY(transactieid) REFERENCES transactie(transactie_id) DEFERRABLE INITIALLY DEFERRED,
FOREIGN KEY(artikelid) REFERENCES artikel(artikel_id) DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO "rol" VALUES(1,'kassa','transacties invoeren');
INSERT INTO "rol" VALUES(2,'beheerder','applicatie beheren');

INSERT INTO "artikeltype" VALUES('nv','ongedefinieerd!','standaard');
INSERT INTO "artikeltype" VALUES('sp','speelgoed','voor speelgoed');
INSERT INTO "artikeltype" VALUES('bk','boek','voor boeken');
INSERT INTO "artikeltype" VALUES('kl','kleding','voor kleding');

INSERT INTO "betaalwijze" VALUES(1,'contant','contante betaling');
INSERT INTO "betaalwijze" VALUES(2,'pin','betaling met pin');

INSERT INTO "kassastatus" VALUES(0,'onbepaald');
INSERT INTO "kassastatus" VALUES(1,'geopend');
INSERT INTO "kassastatus" VALUES(2,'gesloten');


INSERT INTO "vrijwilliger" VALUES( 1,NULL,'','beheerder','wwbeheerder',2);

DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('rol',2);
INSERT INTO "sqlite_sequence" VALUES('verkoper',0);
INSERT INTO "sqlite_sequence" VALUES('beurs',0);
INSERT INTO "sqlite_sequence" VALUES('vrijwilliger',1);
INSERT INTO "sqlite_sequence" VALUES('naw',0);
INSERT INTO "sqlite_sequence" VALUES('beurs_verkoper',0);
INSERT INTO "sqlite_sequence" VALUES('kassa',0);
INSERT INTO "sqlite_sequence" VALUES('klant',0);
INSERT INTO "sqlite_sequence" VALUES('beurs_klant',0);
INSERT INTO "sqlite_sequence" VALUES('transactie',0);
INSERT INTO "sqlite_sequence" VALUES('artikel',0);
INSERT INTO "sqlite_sequence" VALUES('transactieartikel',0);
INSERT INTO "sqlite_sequence" VALUES('kassabedrag',0);
INSERT INTO "sqlite_sequence" VALUES('kassastatus',0);
INSERT INTO "sqlite_sequence" VALUES('kassaopensluit',0);



CREATE TRIGGER update_naw_dtwijzigen AFTER UPDATE ON naw
  BEGIN
    UPDATE naw SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE naw_id = new.naw_id;
  END;
CREATE TRIGGER update_verkoper_verkopercode AFTER INSERT ON verkoper
  BEGIN
    UPDATE verkoper SET verkopercode = new.verkoper_id WHERE verkoper_id = new.verkoper_id and verkopercode='';
  END;
CREATE TRIGGER update_artikel_dtwijzigen AFTER UPDATE ON artikel
  BEGIN
    UPDATE artikel SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE artikel_id = new.artikel_id;
  END;
CREATE TRIGGER update_beurs_klant_dtwijzigen AFTER UPDATE ON beurs_klant
  BEGIN
    UPDATE beurs_klant SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_klant_id = new.beurs_klant_id;
  END;
CREATE TRIGGER update_beurs_verkoper_dtwijzigen AFTER UPDATE ON beurs_verkoper
  BEGIN
    UPDATE beurs_verkoper SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_verkoper_id = new.beurs_verkoper_id;
  END;
CREATE TRIGGER update_beurs_vrijwilliger_dtwijzigen AFTER UPDATE ON beurs_vrijwilliger
  BEGIN
    UPDATE beurs_vrijwilliger SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_vrijwilliger_id = new.beurs_vrijwilliger_id;
  END;
CREATE TRIGGER update_transactie_dtwijzigen AFTER UPDATE ON transactie
  BEGIN
    UPDATE transactie SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE transactie_id = new.transactie_id;
  END;
CREATE TRIGGER update_transactieartikel_dtwijzigen AFTER UPDATE ON transactieartikel
  BEGIN
    UPDATE transactieartikel SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE transactieartikel_id = new.transactieartikel_id;
  END;
CREATE TRIGGER update_kassa_dtwijzigen AFTER UPDATE ON kassa
  BEGIN
    UPDATE kassa SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE kassa_id = new.kassa_id;
  END;
CREATE TRIGGER update_beurs_dtwijzigen AFTER UPDATE ON beurs
  BEGIN
    UPDATE beurs SET datumtijdwijzigen = CURRENT_TIMESTAMP WHERE beurs_id = new.beurs_id;
  END;
COMMIT;




