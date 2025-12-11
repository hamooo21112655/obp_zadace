--Zadatak 1.

--1.
select distinct p.naziv ResNaziv
from pravno_lice p
where p.lokacija_id in (select f.lokacija_id
                        from fizicko_lice f);

--2.
select distinct p.naziv ResNaziv, to_char(u.datum_potpisivanja, 'dd.mm.yyyy') "Datum Potpisivanja"
from pravno_lice p, ugovor_za_pravno_lice u
where p.pravno_lice_id = u.pravno_lice_id and u.datum_potpisivanja > (select min(f.datum_kupoprodaje)
                                                                      from faktura f, proizvod pr, narudzba_proizvoda n
                                                                      where f.faktura_id = n.faktura_id and n.proizvod_id = pr.proizvod_id and pr.broj_mjeseci_garancije is not null);

--3.
select p.naziv
from proizvod p
where p.kategorija_id in (select ka.kategorija_id 
                          from kategorija ka, kolicina n, proizvod p2
                          where p2.kategorija_id = ka.kategorija_id 
                          and n.proizvod_id = p2.proizvod_id
                          having sum(n.kolicina_proizvoda) = (select max(s.sume) from (select sum(k.kolicina_proizvoda) sume
                                                                                       from kolicina k
                                                                                       group by k.proizvod_id) s)
                          group by ka.kategorija_id);

--4.
select p.naziv "Proizvod", pra.naziv "Proizvodjac"
from proizvod p, proizvodjac pro, pravno_lice pra
where p.proizvodjac_id = pro.proizvodjac_id and pra.pravno_lice_id = pro.proizvodjac_id and exists(select 'x' from proizvod p2
                                                                                                   where p2.proizvodjac_id = pro.proizvodjac_id and p2.cijena > (select avg(cijena)
                                                                                                                                                                 from proizvod));

--5.
select distinct fi.ime || ' ' || fi.prezime "Ime i prezime", 
                s.suma_faktura "iznos"
from kupac k, faktura f, fizicko_lice fi, uposlenik u, (select fi2.ime imee, fi2.prezime prezimee, sum(iznos) suma_faktura
                                                        from faktura f2, fizicko_lice fi2, kupac k2
                                                        where k2.kupac_id = f2.kupac_id 
                                                              and fi2.fizicko_lice_id = k2.kupac_id
                                                        group by fi2.ime, fi2.prezime) s                                          
where k.kupac_id = fi.fizicko_lice_id 
      and k.kupac_id = f.kupac_id 
      and u.uposlenik_id = fi.fizicko_lice_id 
      and s.imee = fi.ime 
      and s.prezimee = fi.prezime 
      and s.suma_faktura > (select round(avg(sume), 2) from (select sum(f3.iznos) sume
                                                             from kupac k3, faktura f3, fizicko_lice fi3
                                                             where k3.kupac_id = fi3.fizicko_lice_id 
                                                                   and k3.kupac_id = f3.kupac_id
                                                             group by fi3.ime, fi3.prezime));

--6.
select p.naziv "naziv"
from pravno_lice p
where p.pravno_lice_id in (select k2.kurirska_sluzba_id
                           from narudzba_proizvoda n2, kurirska_sluzba k2, isporuka i2, faktura f2
                           where i2.kurirska_sluzba_id = k2.kurirska_sluzba_id 
                                 and i2.isporuka_id = f2.isporuka_id 
                                 and f2.faktura_id = n2.faktura_id 
                                 and n2.popust_id is not null  
                           group by k2.kurirska_sluzba_id, n2.proizvod_id
                           having sum(n2.kolicina_jednog_proizvoda) = (select max(sume) from (select k.kurirska_sluzba_id, n.proizvod_id, sum(n.kolicina_jednog_proizvoda) sume 
                                                                                              from narudzba_proizvoda n, kurirska_sluzba k, isporuka i, faktura f
                                                                                              where i.kurirska_sluzba_id = k.kurirska_sluzba_id 
                                                                                                    and i.isporuka_id = f.isporuka_id 
                                                                                                    and f.faktura_id = n.faktura_id 
                                                                                                    and n.popust_id is not null
                                                                                              group by k.kurirska_sluzba_id, n.proizvod_id)));

--7.
select u.usteda "Usteda" , fi.ime || ' ' || fi.prezime "Kupac" from (select k.kupac_id idd, sum(p3.cijena * n.kolicina_jednog_proizvoda * po.postotak / 100) usteda
                                                                     from proizvod p3, kupac k, faktura f, narudzba_proizvoda n, popust po
                                                                     where k.kupac_id = f.kupac_id 
                                                                           and n.faktura_id = f.faktura_id 
                                                                           and n.proizvod_id = p3.proizvod_id 
                                                                           and po.popust_id = n.popust_id
                                                                     group by k.kupac_id) u, 
       fizicko_lice fi
where u.idd = fi.fizicko_lice_id;

--8.
select u.isporuka_id idisporuke, i.kurirska_sluzba_id idkurirske from
(select distinct i2.isporuka_id
 from narudzba_proizvoda n2, kurirska_sluzba k2, isporuka i2, faktura f2, proizvod p2
 where i2.kurirska_sluzba_id = k2.kurirska_sluzba_id 
       and i2.isporuka_id = f2.isporuka_id 
       and f2.faktura_id = n2.faktura_id 
       and n2.proizvod_id = p2.proizvod_id
       and n2.popust_id is not null
       and p2.broj_mjeseci_garancije is not null  
union all
select i3.isporuka_id from narudzba_proizvoda n3, kurirska_sluzba k3, isporuka i3, faktura f3, proizvod p3
where i3.kurirska_sluzba_id = k3.kurirska_sluzba_id 
      and i3.isporuka_id = f3.isporuka_id 
      and f3.faktura_id = n3.faktura_id 
      and n3.proizvod_id = p3.proizvod_id
      and (n3.popust_id is null or p3.broj_mjeseci_garancije is null) 
      and i3.isporuka_id not in (select distinct i4.isporuka_id
                                 from narudzba_proizvoda n4, kurirska_sluzba k4, isporuka i4, faktura f4, proizvod p4
                                 where i4.kurirska_sluzba_id = k4.kurirska_sluzba_id 
                                       and i4.isporuka_id = f4.isporuka_id 
                                       and f4.faktura_id = n4.faktura_id 
                                       and n4.proizvod_id = p4.proizvod_id
                                       and n4.popust_id is not null
                                       and p4.broj_mjeseci_garancije is not null)) u, isporuka i
where u.isporuka_id = i.isporuka_id;

--9.
select p2.naziv, p2.cijena
from proizvod p2
where p2.cijena > (select round(avg(max_cijena), 2) from (select k.kategorija_id, k.naziv, max(p.cijena) max_cijena 
                                                          from proizvod p, kategorija k 
                                                          where p.kategorija_id = k.kategorija_id 
                                                          group by k.kategorija_id, k.naziv));

--10.
select p2.naziv, p2.cijena
from proizvod p2, kategorija k2
where p2.kategorija_id = k2.kategorija_id 
      and p2.cijena < all (select avg(p.cijena) 
                           from proizvod p, kategorija k 
                           where p.kategorija_id = k.kategorija_id 
                                 and k2.nadkategorija_id != k.kategorija_id
                           group by k.kategorija_id, k.naziv);

--Zadatak 2.

create table TabelaA
(
    id number,
    naziv varchar(100),
    datum date,
    cijelibroj integer,
    realnibroj number(10, 2),
    constraint provjera_realnog_broja check (realnibroj > 5),
    constraint provjera_cijelog_broja check (cijelibroj not between 5 and 15),
    constraint testA_pk primary key (id)
);

create table TabelaB
(
    id number,
    naziv varchar(100),
    datum date,
    cijelibroj integer,
    realnibroj number(10, 2),
    FKTabelaA number not null,
    constraint FkBnst foreign key (FKTabelaA) references TabelaA (id),
    constraint cijeli_broj_uk unique (cijelibroj)
);

alter table TabelaB add constraint testB_pk primary key (id);

create table TabelaC
(
    id number,
    naziv varchar(100) not null,
    datum date,
    cijelibroj integer not null,
    realnibroj number(10, 2),
    FKTabelaB number,
    constraint FkCnst foreign key (FKtabelaB) references TabelaB (id),
    constraint testC_pk primary key (id)
);

insert into TabelaA 
values (1, 'tekst', null, null, 6.2);

insert into TabelaA  
values (2, null, null, 3, 5.26);

insert into TabelaA  
values (3, 'tekst', null, 1, null);

insert into TabelaA  
values (4, null, null, null, null);

insert into TabelaA  
values (5, 'tekst', null, 16, 6.78);
-------------------------------------
insert into TabelaB 
values (1, null, null, 1, null, 1);

insert into TabelaB 
values (2, null, null, 3, null, 1);

insert into TabelaB 
values (3, null, null, 6, null, 2);

insert into TabelaB 
values (4, null, null, 11, null, 2);

insert into TabelaB 
values (5, null, null, 22, null, 3);
-----------------------------------------
insert into TabelaC
values (1, 'YES', null, 33, null, 4);

insert into TabelaC 
values (2, 'NO', null, 33, null, 2);

insert into TabelaC 
values (3, 'NO', null, 55, null, 1);
-----------------------------------------

--1) Izvrsava se jer nijedan constraint nije narusen niti se unosi red cije kolone ne odgovaraju tipu kolona navedenih prije VALUES.
INSERT INTO TabelaA (id,naziv,datum,cijeliBroj,realniBroj) VALUES (6,'tekst',null,null,6.20); 

--2) Ne izvrsava se jer se narusva constraint cijeli_broj_uk
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,1,null,1); 

--3) Izvrsava se, razlog isti kao i pod 1)
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,123,null,6); 

--4) Izvrsava se, razlog isti kao i pod 1)
INSERT INTO TabelaC (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaB) VALUES (4,'NO',null,55,null,null);

--5) Kolona naziv nema nikakv constraint tako da ce se ova naredba izvrsiti
Update TabelaA set naziv = 'tekst' Where naziv is null and cijeliBroj is not null;

--6) Nece se izvrsiti jer se ovom naredbom narusava referencijalni integritet izmedju tabela TabelaB i TabelaC
Drop table tabelaB;

--7) Nece se izvrsiti jer bi se ovom naredbom obrisao red ciji id se referencira u tabeli TabelaB pa bi se tim narusio referencijalni integritet
Delete from TabelaA where realniBroj is null;

--8) Moze jer se ovom naredbom ne narusava ni jedan constraint
Delete from TabelaA where id = 5;

--9) Moze jer u tabeli TabelaA postoji red ciji je id = 4
Update TabelaB set fktabelaA = 4 where fktabelaA = 2;

--10) Izvrsit ce se. Problem bi bio kada bi vec postojao neki red u tabeli tabelaA koji ima naziv != 'tekst'. Doduse takav red postoji, medjutim odgovarajuca vrijednost je null,
-- a check constraint ignorise null vrijednosti
Alter Table tabelaA add Constraint cst Check (naziv like 'tekst');

--Zadatak 3.

drop table TabelaC;
drop table TabelaB;
drop table TabelaA;

create table TabelaA
(
    id number,
    naziv varchar(100),
    datum date,
    cijelibroj integer,
    realnibroj number(10, 2),
    constraint provjera_realnog_broja check (realnibroj > 5),
    constraint provjera_cijelog_broja check (cijelibroj not between 5 and 15),
    constraint testA_pk primary key (id)
);

create table TabelaB
(
    id number,
    naziv varchar(100),
    datum date,
    cijelibroj integer,
    realnibroj number(10, 2),
    FKTabelaA number not null,
    constraint FkBnst foreign key (FKTabelaA) references TabelaA (id),
    constraint cijeli_broj_uk unique (cijelibroj)
);

alter table TabelaB add constraint testB_pk primary key (id);

create table TabelaC
(
    id number,
    naziv varchar(100) not null,
    datum date,
    cijelibroj integer not null,
    realnibroj number(10, 2),
    FKTabelaB number,
    constraint FkCnst foreign key (FKtabelaB) references TabelaB (id),
    constraint testC_pk primary key (id)
);

insert into TabelaA 
values (1, 'tekst', null, null, 6.2);

insert into TabelaA  
values (2, null, null, 3, 5.26);

insert into TabelaA  
values (3, 'tekst', null, 1, null);

insert into TabelaA  
values (4, null, null, null, null);

insert into TabelaA  
values (5, 'tekst', null, 16, 6.78);
-------------------------------------
insert into TabelaB 
values (1, null, null, 1, null, 1);

insert into TabelaB 
values (2, null, null, 3, null, 1);

insert into TabelaB 
values (3, null, null, 6, null, 2);

insert into TabelaB 
values (4, null, null, 11, null, 2);

insert into TabelaB 
values (5, null, null, 22, null, 3);
-----------------------------------------
insert into TabelaC
values (1, 'YES', null, 33, null, 4);

insert into TabelaC 
values (2, 'NO', null, 33, null, 2);

insert into TabelaC 
values (3, 'NO', null, 55, null, 1);

create sequence seq1
increment by 1
start with 1;

create sequence seq2
increment by 1
start with 1;

create table TabelaABekap
(
    id number,
    naziv varchar(100),
    datum date,
    cijelibroj integer,
    realnibroj number(10, 2),
    cijeliBrojB integer,
    sekvenca integer,
    constraint provjera_realnog_brojat1 check (realnibroj > 5),
    constraint provjera_cijelog_brojat1 check (cijelibroj not between 5 and 15),
    constraint testA_pkt1 primary key (id)
);

create or replace trigger prvitrig18222
after insert 
on TabelaB
for each row
declare
   novi_fk TabelaB.fkTabelaA%type;
   novi_cijeliBrojB TabelaABekap.cijeliBroj%type;
   naziv_zaBekap TabelaABekap.naziv%type;
   datum_zaBekap TabelaABekap.datum%type;
   cijeliBroj_zaBekap TabelaABekap.cijeliBroj%type;
   realniBroj_zaBekap TabelaABekap.realniBroj%type;
   koliko integer;
begin
   novi_fk := :new.fkTabelaA;
   novi_cijeliBrojB := :new.cijeliBroj;
   select count(*) 
   into koliko
   from TabelaABekap b 
   where novi_fk = b.id;
   
   if koliko <> 0 then
        update TabelaABekap t 
        set t.cijeliBrojB = t.cijeliBrojB + novi_cijeliBrojB 
        where t.id = novi_fk;
   else 
        select a.naziv, a.datum, a.cijeliBroj, a.realniBroj
        into naziv_zaBekap, datum_zaBekap, cijeliBroj_zaBekap, realniBroj_zaBekap
        from TabelaA a
        where a.id = novi_fk;
        insert into TabelaABekap values (novi_fk, naziv_zaBekap, datum_zaBekap, cijeliBroj_zaBekap, realniBroj_zaBekap, novi_cijeliBrojB, seq1.nextval);
   end if;  
end; 

CREATE TABLE TabelaBCheck(sekvenca INTEGER PRIMARY KEY);

create or replace trigger drugitrig18222
before delete 
on TabelaB
begin
    insert into TabelaBCheck values (seq2.nextval);
end;

create or replace procedure NazivProcedure18222
(broj in integer)
is 
    suma integer;
    redni_broj integer;
    brojac integer;
begin
    select sum(a.cijeliBroj)
    into suma
    from TabelaA a;

    select max(c.id)
    into redni_broj
    from TabelaC c;

    redni_broj := redni_broj + 1;
    brojac := 1;

    while brojac <= suma loop
        insert into TabelaC values (redni_broj, 'YES', null, broj, null, 1);
        redni_broj := redni_broj + 1;
        brojac := brojac + 1;
    end loop;
end;

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,2,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,4,null,2);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (8,null,null,8,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (9,null,null,5,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (10,null,null,7,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (11,null,null,9,null,5);
Delete From TabelaB where id not in (select FkTabelaB from TabelaC);
Alter TABLE tabelaC drop constraint FkCnst;
Delete from TabelaB where 1=1;
call NazivProcedure18222(1);
--izvrsenje procedure na kraju sa call NazivProcedure(1);
Rezultati poziva su:
Select SUM(id*3 + cijeliBrojB*3) from TabelaABekap; --138
Select Sum(id*3 + cijeliBroj*3) from TabelaC; --1251
Select Sum(MOD(sekvenca,10)*3) from TabelaBCheck; --9
Potrebno je utvditi rezultate poziva:
Select SUM(id*7 + cijeliBrojB*7) from TabelaABekap; --322
Select Sum(id*7 + cijeliBroj*7) from TabelaC; --2919
Select Sum(MOD(sekvenca,10)*7) from TabelaBCheck; --21
