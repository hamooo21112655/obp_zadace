-- 1. Za svaki kontinent prikazati njegove države i gradove. Ako kontinent nema države ispisati ‘Nema
-- države’ a ako nema grada ‘Nema grada’. Kolone nazvati Država, Grad i Kontinent.


select k.naziv as Kontinent, nvl(d.naziv, 'Nema države') as Drzava, nvl(g.naziv, 'Nema grada') as Grad
from kontinent k
full outer join drzava d on k.kontinent_id = d.kontinent_id
full outer join grad g on g.drzava_id = d.drzava_id;

-- 2. Prikazati naziv za sva pravna lica koja su potpisala ugovor izmedju 2014 i 2016. godine (koristiti
-- samo yyyy dio za poredjenje). Potrebno je prikazati rezultate bez ponavljanja.


select distinct naziv from
(select p.naziv, u.datum_potpisivanja 
from PRAVNO_LICE p, ugovor_za_pravno_lice u
where u.pravno_lice_id = p.PRAVNO_LICE_ID and extract(year from  u.datum_potpisivanja) in (2015, 2016));

-- 3. Za svaku državu prikazati kolicinu svakog proizvoda koja se nalazi u skladistima te drzave ako je
-- kolicina proizvoda veca od 50 i naziv drzave ne sadrzi duplo slovo ‘s’. Kolone nazvati Drzava,
-- Proizvod i Kolicina_proizvoda


select d.naziv as Drzava, g.naziv, l.lokacija_id, p.naziv as Proizvod, s.naziv, k.KOLICINA_PROIZVODA as Kolicina_proizvoda
from drzava d, grad g, lokacija l, proizvod p, kolicina k, skladiste s
where d.DRZAVA_ID = g.drzava_id and g.grad_id = l.grad_id and l.lokacija_id = s.lokacija_id and s.skladiste_id = k.skladiste_id and p.proizvod_id = k.proizvod_id
and d.naziv not like '%ss%' and k.KOLICINA_PROIZVODA > 50;

-- 4. Prikazati naziv proizvoda i broj mjeseci garancije za sve proizvode na koje postoji popust a broj
-- mjeseci garancije im je djeljiv sa 3. Potrebno je prikazati rezultate bez ponavljanja.

select distinct naziv as Naziv from
(select p1.naziv, p1.proizvod_id, p1.BROJ_MJESECI_GARANCIJE, p2.postotak, n.POPUST_ID
from proizvod p1, popust p2, NARUDZBA_PROIZVODA n
where p1.proizvod_id = n.PROIZVOD_ID and n.popust_id = p2.POPUST_ID and mod(p1.BROJ_MJESECI_GARANCIJE, 3) = 0);


-- 5. Prikazati kompletno ime i prezime u jednoj koloni i naziv odjela uposlenika koji je ujedno i
-- kupac proizvoda a nije sef tog odjela. Kao vrijednost trece kolone nadodati vaš broj indeksa u
-- svakom redu. Kolone nazvati “ime i prezime”, “Naziv odjela” i “Indeks”.


select f.IME || ' ' || f.PREZIME as "ime i prezime", o.naziv as "Naziv odjela", 18222 as "Indeks" from kupac k, uposlenik u, fizicko_lice f, odjel o
where k.kupac_id = f.fizicko_lice_id and u.uposlenik_id = f.fizicko_lice_id and u.ODJEL_ID = o.ODJEL_ID and not(u.UPOSLENIK_ID = o.sef_id);

-- 6. Za sve narudzbe čiji je popust konvertovan u vrijednost cijene manji od 200 prikazati proizvod,
-- cijenu proizvoda i postotak popusta narudzbe kao cijeli broj (od 0 do 100) i kao realni broj (od 0
-- do 1). Narudzbe koje nemaju popust trebaju biti prikazane kao 0 posto popusta. Nazvati kolone
-- Narudzba_id, Cijena, Postotak i PostotakRealni.


select n.narudzba_id as "NARUDZBA_ID", p1.CIJENA as "CIJENA", nvl(p2.POSTOTAK, 0) as "POSTOTAK", nvl(p2.POSTOTAK / 100, 0) as "postotakrealni", p1.naziv
from narudzba_proizvoda n
inner join proizvod p1 on n.PROIZVOD_ID = p1.PROIZVOD_ID
left outer join popust p2 on p2.popust_id = n.popust_id
where nvl(p2.POSTOTAK / 100, 0) *  p1.CIJENA < 200;

-- 7. Prikazati sve raspolozive kategorije proizvoda i njihove nadkategorije. Ako je id kategorije 1
-- umjesto naziva kategorije treba pisati ‘Komp Oprema’ a ako nema kategorije treba pisati ‘Nema
-- Kategorije’. Nazvati kolone “Kategorija” i “Nadkategorija”


select naziv as "Kategorija", nvl(decode(nadkategorija_id, 1, 'Komp oprema'), 'Nema kategorije') as "Nadkategorija" from kategorija;


-- 9. Prikazati ime i prezime, naziv odjela i id odjela svih uposlenika pri cemu je naziv odjela sa
-- MANAGER ako je u pitanju managment, HUMAN ako su u pitanju ljudski resursi i OTHER za
-- sve ostalo, sortiranih prvo po imenu po rastucem poretku zatim po prezimenu po opadajucem
-- poretku. Kolone nazvati ime prezime, odjel i odjel_id.


select f.ime as ime, f.prezime as prezime, decode(o.naziv, 'Management', 'MANAGER', 'Human Resources', 'HUMAN', 'OTHER') as odjel, o.odjel_id
from fizicko_lice f, odjel o, uposlenik u
where u.UPOSLENIK_ID = f.FIZICKO_LICE_ID and u.ODJEL_ID = o.ODJEL_ID
order by f.ime asc, f.prezime desc;

-- 10. Prikazati svaku kategoriju proizvoda i za svaku kategoriju najskuplji i najjeftiniji proizvod
-- te kategorije i zbir njihovih cijena sortirane po zbiru cijena najjeftinijeg i najskupljeg proizvoda u
-- rastucem poretku. Zbir cijena nazvati ZCijena a proizvode Najjeftiniji i Najskuplji.


select k.naziv, max(p.cijena) as Najskuplji, min(p.cijena) as Najjeftiniji, sum(p.cijena) as Zcijena
from kategorija k, proizvod p
where k.kategorija_id = p.kategorija_id
group by k.naziv, k.kategorija_id
order by Najskuplji + Najjeftiniji;
