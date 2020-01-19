-- phpMyAdmin SQL Dump
-- version 4.8.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Giu 02, 2018 alle 18:32
-- Versione del server: 10.1.31-MariaDB
-- Versione PHP: 7.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `prova`
--

DELIMITER $$
--
-- Funzioni
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CalcoloDanniMossa` (`PartitaGiocata` DATETIME, `TastoMossa` VARCHAR(1)) RETURNS INT(11) BEGIN
    DECLARE DanniFisici INT;
    DECLARE DanniMagici INT;
    
    SET DanniFisici = (SELECT m.Danni_Fisici FROM mossa_campione AS m WHERE m.Tasto = TastoMossa AND  m.Campione = ANY (SELECT partita.Campione_usato 
                                                                                                                        FROM partita 
                                                                                                                        WHERE partita.Cronologia = PartitaGiocata));

    SET DanniMagici = (SELECT m.Danni_Magici FROM mossa_campione AS m WHERE m.Tasto = TastoMossa AND  m.Campione = ANY (SELECT partita.Campione_usato 
                                                                                                                        FROM partita 
                                                                                                                        WHERE partita.Cronologia = PartitaGiocata));


IF DanniFisici > DanniMagici THEN
RETURN DanniFisici + DanniMagici + Calcolo_Statisticha_A_Scelta(PartitaGiocata, "Attacco"); 
ELSE
RETURN DanniFisici + DanniMagici + Calcolo_Statisticha_A_Scelta(PartitaGiocata, "Magia");
END IF;
    
     
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Calcolo_Statisticha_A_Scelta` (`PartitaGiocata` DATETIME, `Statistica` VARCHAR(60)) RETURNS INT(11) BEGIN
    DECLARE AttaccoFisicoIncrementato INT;
    DECLARE PotereMagicoIncremento INT;
    DECLARE DifesaIncrementata INT;
    DECLARE MovimentoIncrementato INT;
    DECLARE Oggetti INT;

IF(Statistica = "Attacco") THEN
    
	SET AttaccoFisicoIncrementato = (SELECT s.Attacco_Fisico
                                     FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN statistiche_campione as s ON s.Nome_campione = p.Campione_usato 
                                     WHERE e.Cronologia = PartitaGiocata) + 
                                    (SELECT r.Incremento_Attacco_Fisico
                                     FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN runa as r ON e.Runa_chiave = r.Nome 
                                     WHERE e.Cronologia = PartitaGiocata);
       SET Oggetti = (SELECT SUM(o.Statistiche_aggiungive)
                      FROM equipaggiamento as e JOIN oggetto as o ON o.Nome = e.Oggetto_Uno OR o.Nome = e.Oggetto_due OR o.Nome = e.Oggetto_tre OR o.Nome = e.Oggetto_quattro
                      WHERE o.Tipologia = "Attacco" AND e.cronologia = PartitaGiocata);

       IF Oggetti IS NULL THEN RETURN AttaccoFisicoIncrementato; 
       ELSE RETURN AttaccoFisicoIncrementato + Oggetti;
       END IF;
END IF;

IF(Statistica = "Magia") THEN
                                     
    SET PotereMagicoIncremento =    (SELECT s.Potere_Magico
                                     FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN statistiche_campione as s ON s.Nome_campione = p.Campione_usato 
                                     WHERE e.Cronologia = PartitaGiocata) + 
                                    (SELECT r.Incremento_Potere_Magico
                                     FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN runa as r ON e.Runa_chiave = r.Nome 
                                     WHERE e.Cronologia = PartitaGiocata);   
    SET Oggetti = (SELECT SUM(o.Statistiche_aggiungive)
                   FROM equipaggiamento as e JOIN oggetto as o ON o.Nome = e.Oggetto_Uno OR o.Nome = e.Oggetto_due OR o.Nome = e.Oggetto_tre OR o.Nome = e.Oggetto_quattro
                   WHERE o.Tipologia = "Magia" AND e.cronologia = PartitaGiocata);

    IF Oggetti IS NULL THEN RETURN PotereMagicoIncremento; 
    ELSE RETURN PotereMagicoIncremento + Oggetti;
    END IF; 
END IF;

IF (Statistica = "Difesa") THEN
                                     
    SET DifesaIncrementata = (SELECT s.Difesa
                              FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN statistiche_campione as s ON s.Nome_campione = p.Campione_usato 
                              WHERE e.Cronologia = PartitaGiocata) + 
                             (SELECT r.Incremento_Difesa
                              FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN runa as r ON e.Runa_chiave = r.Nome 
                              WHERE e.Cronologia = PartitaGiocata);
   SET Oggetti = (SELECT SUM(o.Statistiche_aggiungive)
                  FROM equipaggiamento as e JOIN oggetto as o ON o.Nome = e.Oggetto_Uno OR o.Nome = e.Oggetto_due OR o.Nome = e.Oggetto_tre OR o.Nome = e.Oggetto_quattro
                  WHERE o.Tipologia = "Difesa" AND e.cronologia = PartitaGiocata); 

    IF Oggetti IS NULL THEN RETURN DifesaIncrementata; 
    ELSE RETURN DifesaIncrementata + Oggetti;
    END IF; 
END IF; 

IF (Statistica = "Movimento") THEN
                              
    SET MovimentoIncrementato = (SELECT s.Movimento
                                 FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN statistiche_campione as s ON s.Nome_campione = p.Campione_usato 
                                 WHERE e.Cronologia = PartitaGiocata) + 
                                (SELECT r.Incremento_Movimento
                                 FROM equipaggiamento as e JOIN partita as p ON p.Cronologia = e.Cronologia JOIN runa as r ON e.Runa_chiave = r.Nome 
                                 WHERE e.Cronologia = PartitaGiocata);
   SET Oggetti = (SELECT SUM(o.Statistiche_aggiungive)
                  FROM equipaggiamento as e JOIN oggetto as o ON o.Nome = e.Oggetto_Uno OR o.Nome = e.Oggetto_due OR o.Nome = e.Oggetto_tre OR o.Nome = e.Oggetto_quattro
                  WHERE o.Tipologia = "Movimento" AND e.cronologia = PartitaGiocata);
              
   IF Oggetti IS NULL THEN RETURN MovimentoIncrementato; 
   ELSE RETURN MovimentoIncrementato + Oggetti;
   END IF; 
END IF;
                                 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `aspetto`
--

CREATE TABLE `aspetto` (
  `Nome` varchar(90) NOT NULL,
  `Campione_Possessore` varchar(20) NOT NULL,
  `Costo_in_Essenze` int(11) NOT NULL,
  `Costo_in_Denaro` int(11) NOT NULL,
  `Data_Uscita` date NOT NULL,
  `Tipologia` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `aspetto`
--

INSERT INTO `aspetto` (`Nome`, `Campione_Possessore`, `Costo_in_Essenze`, `Costo_in_Denaro`, `Data_Uscita`, `Tipologia`) VALUES
('Aatrox Cacciatore dei mari', 'Aatrox', 12000, 8, '2014-05-02', 'Classica'),
('Aatrox Giustiziere', 'Aatrox', 22000, 12, '2013-06-13', 'Epica'),
('Ahri Guardiana Stellare', 'Ahri', 30000, 16, '2016-01-24', 'Leggendaria'),
('Ahri Volpe di Fuoco', 'Ahri', 22000, 12, '2011-12-14', 'Epica'),
('Akali Cacciatrice di Teste', 'Akali', 25000, 14, '2015-08-12', 'Leggendaria'),
('Akali Luna di Sangue', 'Akali', 20000, 10, '2010-05-11', 'Epica'),
('Alistar d\'Oro', 'Alistar', 10000, 5, '2009-02-21', 'Classica'),
('Alistar Infernale', 'Alistar', 30000, 16, '2014-11-07', 'Leggendaria'),
('Amumu Festa a Sorpresa', 'Amumu', 25000, 14, '2009-06-26', 'Leggendaria'),
('Amumu Piccolo Cavaliere', 'Amumu', 20000, 10, '2013-04-18', 'Epica'),
('Anivia Nerogelo', 'Anivia', 30000, 16, '2011-07-14', 'Leggendaria'),
('Anivia Preistorica', 'Anivia', 22000, 12, '2009-07-10', 'Epica'),
('Annie Ghiaccio Ardente', 'Annie', 22000, 12, '2009-02-21', 'Epica'),
('Annie Megagalattica', 'Annie', 30000, 16, '2015-02-14', 'Leggendaria'),
('Ashe Ametista', 'Ashe', 22000, 12, '2009-02-21', 'Epica'),
('Aurelion Sol Signore Cinereo', 'Aurelion Sol', 30000, 16, '2016-03-24', 'Leggendaria'),
('Azir Galattico', 'Azir', 22000, 12, '2014-09-16', 'Epica'),
('Azir Signore delle tombe', 'Azir', 30000, 16, '2016-12-15', 'Leggendaria'),
('Bard del Bosco Antico', 'Bard', 10000, 5, '2016-04-06', 'Classica'),
('Bard della Nevicata', 'Bard', 12000, 8, '2015-03-12', 'Classica'),
('Blitzcrank Lanciere Eroico', 'Blitzcrank', 25000, 14, '2017-10-26', 'Leggendaria'),
('Brand Apocalittico', 'Brand', 12000, 8, '2012-03-28', 'Classica'),
('Brand Crio-nucleo', 'Brand', 22000, 12, '2011-04-12', 'Epica'),
('Braum Ammazzadraghi', 'Braum', 25000, 14, '2014-05-12', 'Leggendaria'),
('Braum El Tigre', 'Braum', 22000, 12, '2016-04-17', 'Epica'),
('Caitlyn Cacciatrice di Teste', 'Caitlyn', 30000, 16, '2015-07-12', 'Leggendaria'),
('Caitlyn Guerra Artica', 'Caitlyn', 12000, 8, '2011-01-04', 'Classica'),
('Caitlyn Pulsefire', 'Caitlyn', 45000, 20, '2017-04-18', 'Suprema'),
('Cyber-pop Zoe', 'Zoe', 30000, 16, '2017-11-21', 'Leggendaria'),
('DJ Sona', 'Sona', 45000, 20, '2010-09-21', 'Suprema'),
('Draven Festa in Piscina', 'Draven', 12000, 8, '2015-08-21', 'Classica'),
('Draven Gladiatore', 'Draven', 25000, 14, '2012-06-06', 'Leggendaria'),
('Draven Predatore di Anime', 'Draven', 30000, 16, '2014-02-11', 'Leggendaria'),
('Ekko dell\'Accademia', 'Ekko', 12000, 8, '2016-05-05', 'Classica'),
('Ekko Tempesta di Sabbia', 'Ekko', 25000, 14, '2015-05-28', 'Leggendaria'),
('Ezreal dei Ghiacci', 'Ezreal', 10000, 5, '2010-03-16', 'Classica'),
('Ezreal Pulsefire', 'Ezreal', 45000, 20, '2012-11-09', 'Suprema'),
('Fiora Guardia Reale', 'Fiora', 10000, 5, '2012-02-29', 'Classica'),
('Fiora Spada Alata', 'Fiora', 22000, 12, '2014-04-21', 'Epica'),
('Galio Commando', 'Galio', 10000, 5, '2010-08-10', 'Classica'),
('Galio Guardiano', 'Galio', 22000, 12, '2013-07-28', 'Epica'),
('Graves Festa in Piscina', 'Graves', 25000, 14, '2014-03-18', 'Leggendaria'),
('Graves Mercenario', 'Graves', 12000, 8, '2011-10-19', 'Classica'),
('iBlitzcrank', 'Blitzcrank', 30000, 16, '2009-09-02', 'Leggendaria'),
('Irelia Gladio Ghiacciato', 'Irelia', 30000, 16, '2012-09-28', 'Leggendaria'),
('Irelia Lama della Notte', 'Irelia', 22000, 12, '2010-11-16', 'Epica'),
('Janna Meteorina', 'Janna', 30000, 16, '2009-09-02', 'Leggendaria'),
('Janna Tempesta dei Venti', 'Janna', 10000, 5, '2011-03-12', 'Classica'),
('Jhin Luna di Sangue', 'Jhin', 20000, 10, '2017-12-02', 'Epica'),
('Jhin Mezzogiorno di Fuoco', 'Jhin', 25000, 14, '2016-02-01', 'Leggendaria'),
('Kalista Luna di Sangue', 'Kalista', 22000, 12, '2014-11-20', 'Epica'),
('Kassadin Mietitore Cosmico', 'Kassadin', 30000, 16, '2016-10-20', 'Leggendaria'),
('Kassadin Vuoto Cosmico', 'Kassadin', 10000, 5, '2009-08-07', 'Classica'),
('Kindred Fuoco Fatuo', 'Kindred', 22000, 12, '2015-12-16', 'Epica'),
('Kindred Megagalattico', 'Kindred', 25000, 14, '2015-10-14', 'Leggendaria'),
('Leona dei Solari', 'Leona', 12000, 8, '2013-03-12', 'Classica'),
('Lucian capocannoniere', 'Lucian', 20000, 10, '2014-08-01', 'Epica'),
('Lucian Mercenario', 'Lucian', 22000, 12, '2013-08-22', 'Epica'),
('Marchese Vladimir', 'Vladimir', 10000, 5, '2012-03-20', 'Classica'),
('Master Yi Cacciatore di Teste', 'Master Yi', 12000, 8, '2009-02-21', 'Classica'),
('Master Yi Tempio Antico', 'Master Yi', 10000, 5, '2010-05-10', 'Classica'),
('Mecha Aatrox', 'Aatrox', 25000, 14, '2015-09-22', 'Leggendaria'),
('Morgana Aculeo Nero', 'Morgana', 25000, 14, '2011-03-17', 'Leggendaria'),
('Morgana Sposa Spettrale', 'Morgana', 25000, 14, '2009-02-21', 'Leggendaria'),
('Nami delle Profondità', 'Nami', 25000, 14, '2013-07-04', 'Leggendaria'),
('Nami Koi', 'Nami', 22000, 12, '2012-12-07', 'Epica'),
('Nunu Demolitore', 'Nunu', 22000, 12, '2012-11-20', 'Epica'),
('Nunu-bot', 'Nunu', 30000, 16, '2009-02-21', 'Leggendaria'),
('Olaf dei Pentakill', 'Olaf', 20000, 10, '2012-03-06', 'Epica'),
('Olaf Predone', 'Olaf', 10000, 5, '2010-06-09', 'Classica'),
('Pantheon Ammazzadraghi', 'Pantheon', 30000, 16, '2014-09-04', 'Leggendaria'),
('Pantheon Mirmidone', 'Pantheon', 10000, 5, '2010-02-02', 'Classica'),
('PROGETTO: Ashe', 'Ashe', 30000, 16, '2017-05-16', 'Leggendaria'),
('PROGETTO: Fiora', 'Fiora', 25000, 14, '2015-02-23', 'Leggendaria'),
('PROGETTO:Leona', 'Leona', 25000, 14, '2011-07-13', 'Leggendaria'),
('PROGETTO:Vayne', 'Vayne', 45000, 20, '2017-01-22', 'Suprema'),
('PROGETTO:Zed', 'Zed', 25000, 14, '2014-08-24', 'Leggendaria'),
('Programma Camille', 'Camille', 25000, 14, '2016-12-07', 'Leggendaria'),
('Rakan Alba Cosmica', 'Rakan', 25000, 14, '2017-04-19', 'Leggendaria'),
('Rakan del Cuore', 'Rakan', 22000, 12, '2017-11-26', 'Epica'),
('Rengar Cacciatore di Teste', 'Rengar', 22000, 12, '2012-08-21', 'Epica'),
('Rengar Cacciatore Notturno', 'Rengar', 20000, 10, '2015-01-18', 'Epica'),
('Samurai Yi', 'Master Yi', 20000, 10, '2015-04-11', 'Epica'),
('Skarner Guardiano delle Sabbie', 'Skarner', 10000, 5, '2011-08-09', 'Classica'),
('Skarner Terra Runica', 'Skarner', 12000, 8, '2013-07-09', 'Classica'),
('Sona dei Pentakill', 'Sona', 20000, 10, '2014-08-20', 'Epica'),
('Thresh Stella Oscura', 'Thresh', 30000, 16, '2017-05-12', 'Leggendaria'),
('Thresh Terrore Profondo', 'Thresh', 22000, 12, '2013-01-23', 'Epica'),
('Varus Cristalli del Flagello', 'Varus', 22000, 12, '2014-07-15', 'Epica'),
('Varus Operazioni Artiche', 'Varus', 25000, 14, '2012-05-08', 'Leggendaria'),
('Vayne Aristocratica', 'Vayne', 25000, 14, '2011-05-10', 'Leggendaria'),
('Vladimir Signore del Sangue', 'Vladimir', 25000, 14, '2010-07-27', 'Leggendaria'),
('Xayah Crepuscolo Cosmico', 'Xayah', 25000, 14, '2017-04-19', 'Leggendaria'),
('Yasuo Luna di Sangue', 'Yasuo', 30000, 16, '2014-12-09', 'Leggendaria'),
('Yasuo Mezzogiorno di Fuoco', 'Yasuo', 20000, 10, '2013-12-13', 'Epica'),
('Zed Elettrolama', 'Zed', 10000, 5, '2012-11-13', 'Classica');

-- --------------------------------------------------------

--
-- Struttura della tabella `aspetto_posseduto`
--

CREATE TABLE `aspetto_posseduto` (
  `Nome` varchar(90) NOT NULL,
  `Proprietario` varchar(40) NOT NULL,
  `Data_Acquisizione` date NOT NULL,
  `Modalità_Acquisto` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `aspetto_posseduto`
--

INSERT INTO `aspetto_posseduto` (`Nome`, `Proprietario`, `Data_Acquisizione`, `Modalità_Acquisto`) VALUES
('Aatrox Giustiziere', 'dracos777', '2014-09-21', 'Denaro'),
('Aatrox Giustiziere', 'xTigerMaster', '2016-04-22', 'Denaro'),
('Ahri Volpe di Fuoco', 'Deumion', '2016-08-27', 'Denaro'),
('Akali Cacciatrice di Teste', 'dracos777', '2015-01-26', 'Essenze'),
('Alistar Infernale', 'Deumion', '2017-11-09', 'Denaro'),
('Anivia Nerogelo', 'CrazyBirraiol', '2018-01-25', 'Denaro'),
('Anivia Preistorica', 'CrazyBirraiol', '2018-02-17', 'Denaro'),
('Ashe Ametista', 'DarkVo0doo', '2016-11-19', 'Essenze'),
('Azir Galattico', 'dracos777', '2016-09-23', 'Denaro'),
('Azir Signore delle tombe', 'Hiken96', '2017-01-23', 'Denaro'),
('Blitzcrank Lanciere Eroico', 'howIrain', '2018-03-10', 'Denaro'),
('Brand Apocalittico', 'dracos777', '2016-08-17', 'Essenze'),
('Brand Crio-nucleo', 'Deumion', '2016-03-15', 'Essenze'),
('Braum Ammazzadraghi', 'Master Shuppets', '2018-02-15', 'Essenze'),
('Caitlyn Cacciatrice di Teste', 'Oh My Darph', '2016-01-19', 'Denaro'),
('Ekko Tempesta di Sabbia', 'MirrorUp', '2014-09-25', 'Denaro'),
('Ezreal Pulsefire', 'CanonStylus', '2016-06-16', 'Denaro'),
('Graves Mercenario', 'DarkVo0doo', '2017-09-23', 'Essenze'),
('iBlitzcrank', 'dracos777', '2016-05-19', 'Denaro'),
('Janna Meteorina', 'howIrain', '2014-04-23', 'Essenze'),
('Jhin Luna di Sangue', 'xTigerMaster', '2017-07-29', 'Denaro'),
('Jhin Mezzogiorno di Fuoco', 'DarkVo0doo', '2017-12-08', 'Denaro'),
('Kalista Luna di Sangue', 'dracos777', '2014-11-20', 'Denaro'),
('Lucian Mercenario', 'xTigerMaster', '2016-04-02', 'Essenze'),
('Master Yi Cacciatore di Teste', 'LaMaggica', '2017-06-22', 'Denaro'),
('Pantheon Ammazzadraghi', 'LaMaggica', '2016-09-14', 'Denaro'),
('PROGETTO: Fiora', 'Mario889', '2016-05-12', 'Denaro'),
('PROGETTO:Leona', 'Master Shuppets', '2017-05-10', 'Denaro'),
('PROGETTO:Vayne', 'DarkVo0doo', '2017-12-09', 'Denaro'),
('Programma Camille', 'xTigerMaster', '2017-08-10', 'Denaro'),
('Rakan Alba Cosmica', 'Master Shuppets', '2017-10-25', 'Denaro'),
('Skarner Terra Runica', 'CanonStylus', '2016-09-21', 'Denaro'),
('Thresh Stella Oscura', 'CanonStylus', '2014-12-20', 'Denaro'),
('Yasuo Luna di Sangue', 'Hiken96', '2015-06-21', 'Denaro'),
('Yasuo Mezzogiorno di Fuoco', 'Hiken96', '2018-04-11', 'Denaro'),
('Zed Elettrolama', 'MirrorUp', '2012-10-13', 'Denaro');

-- --------------------------------------------------------

--
-- Struttura della tabella `campione`
--

CREATE TABLE `campione` (
  `Nome` varchar(20) NOT NULL,
  `Data_Rilascio` date NOT NULL,
  `Costo_in_Denaro` int(11) NOT NULL,
  `Costo_in_Essenze` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `campione`
--

INSERT INTO `campione` (`Nome`, `Data_Rilascio`, `Costo_in_Denaro`, `Costo_in_Essenze`) VALUES
('Aatrox', '2013-06-13', 10, 6300),
('Ahri', '2011-12-14', 8, 4800),
('Akali', '2010-05-11', 6, 3150),
('Alistar', '2009-02-21', 4, 1350),
('Amumu', '2009-06-26', 2, 450),
('Anivia', '2009-07-10', 6, 3150),
('Annie', '2009-02-21', 2, 450),
('Ashe', '2009-02-21', 2, 450),
('Aurelion Sol', '2016-03-24', 10, 6300),
('Azir', '2014-09-16', 10, 6300),
('Bard', '2015-03-12', 10, 6300),
('Blitzcrank', '2009-09-02', 6, 3150),
('Brand', '2011-04-12', 8, 4800),
('Braum', '2014-05-12', 10, 6300),
('Caitlyn', '2011-01-04', 8, 4800),
('Camille', '2016-12-07', 10, 6300),
('Draven', '2012-06-06', 10, 6300),
('Ekko', '2015-05-28', 10, 6300),
('Ezreal', '2010-03-16', 8, 4800),
('Fiora', '2012-02-29', 8, 4800),
('Galio', '2010-08-10', 6, 3150),
('Graves', '2011-10-19', 8, 4800),
('Irelia', '2010-11-16', 8, 4800),
('Janna', '2009-09-02', 4, 1350),
('Jhin', '2016-02-01', 10, 6300),
('Kalista', '2014-11-20', 10, 6300),
('Kassadin', '2009-08-07', 6, 3150),
('Kindred', '2015-10-14', 10, 6300),
('Leona', '2011-07-13', 8, 4800),
('Lucian', '2013-08-22', 10, 6300),
('Master Yi', '2009-02-21', 2, 450),
('Morgana', '2009-02-21', 4, 1350),
('Nami', '2012-12-07', 8, 4800),
('Nunu', '2009-02-21', 2, 450),
('Olaf', '2010-06-09', 6, 3150),
('Pantheon', '2010-02-02', 6, 3150),
('Rakan', '2017-04-19', 10, 6300),
('Rengar', '2012-08-21', 8, 4800),
('Skarner', '2011-08-09', 8, 4800),
('Sona', '2010-09-21', 6, 3150),
('Thresh', '2013-01-23', 10, 6300),
('Varus', '2012-05-08', 8, 4800),
('Vayne', '2011-05-10', 8, 4800),
('Vladimir', '2010-07-27', 8, 4800),
('Xayah', '2017-04-19', 10, 6300),
('Yasuo', '2013-12-13', 10, 6300),
('Zed', '2012-11-13', 8, 4800),
('Zoe', '2017-11-21', 10, 6300);

--
-- Trigger `campione`
--
DELIMITER $$
CREATE TRIGGER `Nuovo Campione` AFTER INSERT ON `campione` FOR EACH ROW BEGIN
	INSERT INTO mossa_campione VALUES ("Aggiungi nome mossa Q", "Q", "Aggiungi descrizione mossa Q", New.Nome, 0, 0);
        INSERT INTO mossa_campione VALUES ("Aggiungi nome mossa w", "W", "Aggiungi descrizione mossa w", New.Nome, 0, 0);
        INSERT INTO mossa_campione VALUES ("Aggiungi nome mossa E", "E", "Aggiungi descrizione mossa E", New.Nome, 0, 0);
        INSERT INTO mossa_campione VALUES ("Aggiungi nome mossa R", "R", "Aggiungi descrizione mossa R", New.Nome, 0, 0);
        INSERT INTO informazioni_campione VALUES (New.Nome, "Aggiungi Genere", "Aggiungi corsia principale", "Aggiungi corsia secondaria");
        INSERT INTO statistiche_campione VALUES (New.Nome, 0, 0, 0, 0);
        INSERT INTO aspetto VALUES ("Aggiungere nome aspetto", New.Nome, 0, 0, NEW.Data_Rilascio, "Inserire Tipologia" );		            
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `campione_posseduto`
--

CREATE TABLE `campione_posseduto` (
  `Possessore` varchar(40) NOT NULL,
  `Nome_Campione` varchar(20) NOT NULL,
  `Maestria` int(11) DEFAULT NULL,
  `Data_Acquisizione` date NOT NULL,
  `Modalità_Acquisto` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `campione_posseduto`
--

INSERT INTO `campione_posseduto` (`Possessore`, `Nome_Campione`, `Maestria`, `Data_Acquisizione`, `Modalità_Acquisto`) VALUES
('Ayrok', 'Ahri', 5, '2015-11-02', 'Essenze'),
('Ayrok', 'Ashe', NULL, '2015-06-03', 'Denaro'),
('CanonStylus', 'Ezreal', NULL, '2015-12-09', 'Essenze'),
('CanonStylus', 'Skarner', NULL, '2016-03-04', 'Essenze'),
('CanonStylus', 'Thresh', 7, '2014-09-21', 'Denaro'),
('CanonStylus', 'Vayne', NULL, '2015-09-23', 'Essenze'),
('CanonStylus', 'Zoe', NULL, '2018-03-01', 'Essenze'),
('CrazyBirraiol', 'Anivia', 6, '2017-11-03', 'Essenze'),
('CrazyBirraiol', 'Nunu', 4, '2017-01-10', 'Essenze'),
('CrazyBirraiol', 'Vladimir', NULL, '2018-02-14', 'Denaro'),
('DarkVo0doo', 'Ashe', 6, '2016-09-24', 'Essenze'),
('DarkVo0doo', 'Graves', 6, '2017-07-04', 'Essenze'),
('DarkVo0doo', 'Jhin', 7, '2017-02-20', 'Essenze'),
('DarkVo0doo', 'Vayne', 7, '2016-04-24', 'Essenze'),
('Deumion', 'Ahri', 6, '2015-09-12', 'Essenze'),
('Deumion', 'Alistar', 4, '2017-07-23', 'Essenze'),
('Deumion', 'Ashe', 4, '2016-06-12', 'Essenze'),
('Deumion', 'Brand', 6, '2015-07-17', 'Essenze'),
('Deumion', 'Ekko', 4, '2016-08-09', 'Essenze'),
('Deumion', 'Ezreal', NULL, '2016-02-19', 'Essenze'),
('Deumion', 'Xayah', 4, '2017-04-19', 'Denaro'),
('Deumion', 'Yasuo', 7, '2016-06-24', 'Essenze'),
('dracos777', 'Aatrox', 7, '2013-09-24', 'Essenze'),
('dracos777', 'Akali', 7, '2013-06-07', 'Denaro'),
('dracos777', 'Alistar', 6, '2012-08-26', 'Essenze'),
('dracos777', 'Amumu', 5, '2012-09-23', 'Denaro'),
('dracos777', 'Ashe', NULL, '2014-05-12', 'Denaro'),
('dracos777', 'Azir', NULL, '2015-07-08', 'Essenze'),
('dracos777', 'Blitzcrank', 5, '2014-08-24', 'Essenze'),
('dracos777', 'Braum', NULL, '2015-02-26', 'Essenze'),
('dracos777', 'Fiora', 6, '2012-03-29', 'Denaro'),
('dracos777', 'Kalista', 7, '2014-11-20', 'Denaro'),
('dracos777', 'Morgana', 7, '2011-11-01', 'Essenze'),
('dracos777', 'Xayah', 7, '2017-04-19', 'Denaro'),
('dracos777', 'Yasuo', 7, '2014-02-12', 'Essenze'),
('dracos777', 'Zoe', 6, '2017-11-21', 'Essenze'),
('Felix889', 'Aatrox', 7, '2016-01-12', 'Denaro'),
('Felix889', 'Ahri', 6, '2015-11-03', 'Denaro'),
('Felix889', 'Aurelion Sol', 7, '2016-04-20', 'Essenze'),
('Felix889', 'Draven', 7, '2016-01-24', 'Essenze'),
('Felix889', 'Galio', 6, '2015-11-08', 'Denaro'),
('Felix889', 'Lucian', 7, '2016-12-11', 'Denaro'),
('Felix889', 'Varus', 4, '2015-12-30', 'Essenze'),
('Felix889', 'Zed', 7, '2016-11-10', 'Essenze'),
('Hiken96', 'Aurelion Sol', 4, '2018-06-22', 'Essenze'),
('Hiken96', 'Azir', 5, '2015-03-19', 'Denaro'),
('Hiken96', 'Camille', 4, '2016-12-07', 'Essenze'),
('Hiken96', 'Galio', NULL, '2015-07-20', 'Essenze'),
('Hiken96', 'Yasuo', 7, '2014-12-09', 'Essenze'),
('howIrain', 'Blitzcrank', 7, '2015-06-21', 'Essenze'),
('howIrain', 'Janna', 6, '2012-07-18', 'Essenze'),
('howIrain', 'Kassadin', NULL, '2012-09-28', 'Essenze'),
('howIrain', 'Thresh', 5, '2014-08-24', 'Essenze'),
('howIrain', 'Vayne', 4, '2017-02-11', 'Essenze'),
('LaMaggica', 'Aurelion Sol', 5, '2016-08-23', 'Essenze'),
('LaMaggica', 'Draven', 7, '2016-04-20', 'Essenze'),
('LaMaggica', 'Ekko', 5, '2017-09-17', 'Essenze'),
('LaMaggica', 'Ezreal', 5, '2016-04-21', 'Essenze'),
('LaMaggica', 'Janna', 7, '2017-03-21', 'Essenze'),
('LaMaggica', 'Master Yi', 7, '2016-11-04', 'Essenze'),
('LaMaggica', 'Pantheon', NULL, '2016-06-23', 'Essenze'),
('Mario889', 'Akali', 7, '2012-09-25', 'Essenze'),
('Mario889', 'Amumu', 6, '2011-05-12', 'Essenze'),
('Mario889', 'Anivia', NULL, '2013-10-14', 'Essenze'),
('Mario889', 'Annie', NULL, '2011-07-20', 'Essenze'),
('Mario889', 'Aurelion Sol', 6, '2018-05-16', 'Essenze'),
('Mario889', 'Blitzcrank', NULL, '2012-06-06', 'Essenze'),
('Mario889', 'Fiora', NULL, '2012-12-28', 'Essenze'),
('Mario889', 'Jhin', 5, '2016-02-01', 'Denaro'),
('Mario889', 'Kassadin', NULL, '2010-09-13', 'Essenze'),
('Mario889', 'Nami', NULL, '2014-03-17', 'Essenze'),
('Mario889', 'Olaf', 4, '2013-04-19', 'Essenze'),
('Mario889', 'Pantheon', 6, '2011-08-26', 'Denaro'),
('Master Shuppets', 'Akali', 5, '2018-04-16', 'Denaro'),
('Master Shuppets', 'Annie', 6, '2017-07-21', 'Essenze'),
('Master Shuppets', 'Braum', 5, '2017-09-20', 'Essenze'),
('Master Shuppets', 'Galio', 4, '2017-02-01', 'Denaro'),
('Master Shuppets', 'Leona', 6, '2017-02-17', 'Essenze'),
('Master Shuppets', 'Rakan', 4, '2017-05-01', 'Essenze'),
('MirrorUp', 'Alistar', 5, '2011-09-23', 'Essenze'),
('MirrorUp', 'Amumu', 5, '2012-05-23', 'Essenze'),
('MirrorUp', 'Brand', 6, '2011-08-07', 'Essenze'),
('MirrorUp', 'Ekko', 5, '2014-09-25', 'Denaro'),
('MirrorUp', 'Zed', 7, '2012-10-13', 'Essenze'),
('Oh My Darph', 'Ashe', NULL, '2017-03-19', 'Denaro'),
('Oh My Darph', 'Bard', 7, '2015-03-12', 'Denaro'),
('Oh My Darph', 'Caitlyn', 4, '2015-01-26', 'Essenze'),
('Oh My Darph', 'Xayah', NULL, '2017-05-12', 'Essenze'),
('xTigerMaster', 'Aatrox', 7, '2016-03-07', 'Essenze'),
('xTigerMaster', 'Akali', 4, '2015-10-16', 'Essenze'),
('xTigerMaster', 'Aurelion Sol', NULL, '2016-12-24', 'Denaro'),
('xTigerMaster', 'Blitzcrank', NULL, '2016-09-03', 'Essenze'),
('xTigerMaster', 'Camille', 5, '2016-12-07', 'Essenze'),
('xTigerMaster', 'Jhin', 6, '2016-03-01', 'Essenze'),
('xTigerMaster', 'Lucian', 6, '2015-03-21', 'Denaro'),
('xTigerMaster', 'Rengar', 4, '2015-12-13', 'Essenze'),
('xTigerMaster', 'Vladimir', NULL, '2015-09-21', 'Denaro'),
('xXDarkXx', 'Aatrox', NULL, '2018-03-19', 'Essenze'),
('xXDarkXx', 'Ezreal', NULL, '2018-02-27', 'Denaro'),
('xXDarkXx', 'Leona', NULL, '2018-02-22', 'Denaro'),
('xXDarkXx', 'Nunu', NULL, '2018-02-19', 'Denaro');

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `campioni_più_acquistati_in_corsia_centrale`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `campioni_più_acquistati_in_corsia_centrale` (
`Nome` varchar(20)
,`Possessori` bigint(21)
);

-- --------------------------------------------------------

--
-- Struttura della tabella `classificata`
--

CREATE TABLE `classificata` (
  `Cronologia` datetime NOT NULL,
  `Evocatore` varchar(40) NOT NULL,
  `Punti` decimal(10,0) DEFAULT NULL,
  `Tipologia` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `classificata`
--

INSERT INTO `classificata` (`Cronologia`, `Evocatore`, `Punti`, `Tipologia`) VALUES
('2018-02-09 13:25:34', 'Master Shuppets', '10', 'Solo/Duo'),
('2018-03-07 15:23:21', 'MirrorUp', '20', 'Solo/Duo'),
('2018-03-20 21:27:07', 'xTigerMaster', '-23', 'Flex'),
('2018-04-02 08:50:00', 'DarkVo0doo', '50', 'Flex'),
('2018-04-05 13:24:18', 'LaMaggica', '-18', 'Solo/Duo'),
('2018-04-12 16:59:35', 'Hiken96', '10', 'Flex'),
('2018-04-16 10:24:19', 'DarkVo0doo', '-18', 'Solo/Duo'),
('2018-04-26 15:29:42', 'Master Shuppets', '150', 'Flex'),
('2018-04-28 15:32:29', 'MirrorUp', '-13', 'Solo/Duo'),
('2018-05-01 09:30:11', 'Master Shuppets', '24', 'SoloDuo'),
('2018-05-04 22:35:16', 'MirrorUp', '-14', 'Solo/Duo'),
('2018-05-13 14:23:08', 'Oh My Darph', '-23', 'SoloDuo'),
('2018-05-30 17:16:08', 'CanonStylus', '25', 'Solo/Duo'),
('2018-05-30 21:29:00', 'Mario889', '23', 'SoloDuo'),
('2018-05-31 11:18:13', 'Mario889', '20', 'Solo/Duo');

--
-- Trigger `classificata`
--
DELIMITER $$
CREATE TRIGGER `Aggiorno Classifiche Flex` AFTER INSERT ON `classificata` FOR EACH ROW BEGIN
DECLARE NOME VARCHAR(30);
DECLARE PuntiAux INT;
DECLARE DivAux INT;
DECLARE LegaAux INT;

IF NEW.Tipologia = "Flex" THEN 

   SET NOME = (SELECT p.Evocatore FROM partita AS p WHERE p.Cronologia = NEW.Cronologia);
   SET DivAux = (SELECT cla.Divisione_Flex FROM classifiche as cla WHERE cla.Utente = NEW.Evocatore);
   SET PuntiAux = (SELECT cla.Numero_Punti_Flex FROM classifiche as cla WHERE cla.Utente = NEW.Evocatore);
   SET LegaAux = (SELECT cla.ID_Lega_Flex FROM classifiche as cla WHERE cla.Utente = NEW.Evocatore);

   IF(PuntiAux + NEW.Punti) < 0 THEN

         IF LegaAux = 5 AND DivAux = 5 THEN
            UPDATE classifiche
            SET Numero_Punti_Flex = 0
            WHERE Utente = NOME;
         ELSE
             IF DivAux = 5 THEN
                   UPDATE classifiche
                   SET ID_Lega_Flex = ID_Lega_Flex + 1, Numero_Punti_Flex = 0, Divisione_Flex = 1
                   WHERE Utente = NOME;
             ELSE 
                   UPDATE classifiche
                   SET Numero_Punti_Flex = 0, Divisione_Flex = Divisione_Flex + 1
                   WHERE Utente = NOME;
             END IF; 
         END IF;

   ELSE  
          IF(PuntiAux + NEW.Punti) > 100 THEN
      
             IF (LegaAux = 1 AND DivAux = 1) THEN
                UPDATE classifiche 
                SET Numero_Punti_Flex = 100
                WHERE Utente = NOME;
             ELSE
                  IF DivAux = 1 THEN
                     UPDATE classifiche
                     SET ID_Lega_Flex = ID_Lega_Flex - 1, Numero_Punti_Flex = 0, Divisione_Flex = 5
                     WHERE Utente = NOME; 
                  ELSE 
                     UPDATE classifiche 
                     SET Numero_Punti_Flex = 0, Divisione_Flex = Divisione_Flex - 1
                     WHERE Utente = NOME;
                  END IF;
             END IF;
          
          ELSE 
                UPDATE classifiche
                SET Numero_Punti_Flex = Numero_Punti_Flex + NEW.Punti
                WHERE Utente = NOME;
          END IF;
   END IF;
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `classifica_spese_aspetti`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `classifica_spese_aspetti` (
`Proprietario` varchar(40)
,`Denaro_speso` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Struttura della tabella `classifiche`
--

CREATE TABLE `classifiche` (
  `Utente` varchar(40) NOT NULL,
  `Nome_Classifica` varchar(100) DEFAULT NULL,
  `ID_Lega_SoloDuo` int(11) DEFAULT NULL,
  `Divisione_SoloDuo` int(11) DEFAULT NULL,
  `Numero_Punti_SoloDuo` int(11) DEFAULT NULL,
  `ID_Lega_Flex` int(11) DEFAULT NULL,
  `Divisione_Flex` int(11) DEFAULT NULL,
  `Numero_Punti_Flex` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `classifiche`
--

INSERT INTO `classifiche` (`Utente`, `Nome_Classifica`, `ID_Lega_SoloDuo`, `Divisione_SoloDuo`, `Numero_Punti_SoloDuo`, `ID_Lega_Flex`, `Divisione_Flex`, `Numero_Punti_Flex`) VALUES
('CanonStylus', 'L\'Elite di Jax', 3, 5, 12, 4, 1, 90),
('CrazyBirraiol', 'L\'Artiglieria di Swain', 2, 2, 45, 3, 1, 90),
('DarkVo0doo', 'La Guardia di Ezreal', 1, 4, 10, 2, 2, 0),
('Deumion', 'I Fulmini di Blitzcrank', NULL, NULL, NULL, 2, 1, 50),
('dracos777', 'Le Frecce di Twitch', 2, 1, 67, 1, 3, 45),
('Felix889', 'I Capitani di Olaf', 1, 2, 56, 1, 1, 90),
('Hiken96', 'I Capitani di Talon', 3, 3, 45, 2, 5, 23),
('howIrain', 'Gli Sciamani di Aatrox', 2, 5, 78, NULL, NULL, NULL),
('LaMaggica', 'I Capitani di Olaf', 2, 2, 45, NULL, NULL, NULL),
('Mario889', 'Gli Sciamani di Aatrox', 1, 1, 90, 1, 1, 100),
('Master Shuppets', 'Il Destino di Jax', 1, 5, 0, 2, 5, 0),
('MirrorUp', 'Le Fiamme di Brand', 1, 2, 90, 1, 1, 90),
('Oh My Darph', 'Gli Sciamani di Aatrox', 5, 5, 24, NULL, NULL, NULL),
('xTigerMaster', 'Gli Orologi di Ekko', 2, 3, 56, 3, 1, 99);

-- --------------------------------------------------------

--
-- Struttura della tabella `club`
--

CREATE TABLE `club` (
  `Nome` varchar(30) NOT NULL,
  `Data_Creazione` date NOT NULL,
  `Capo` varchar(40) NOT NULL,
  `Tag` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `club`
--

INSERT INTO `club` (`Nome`, `Data_Creazione`, `Capo`, `Tag`) VALUES
('Cloud9', '2015-12-19', 'DarkVo0doo', 'C9'),
('Counter Logic Game', '2014-05-17', 'MirrorUp', 'CLG'),
('H2K', '2012-02-19', 'Mario889', 'H2K'),
('Rox Tiger', '2015-08-02', 'Mario889', 'Rox');

-- --------------------------------------------------------

--
-- Struttura della tabella `equipaggiamento`
--

CREATE TABLE `equipaggiamento` (
  `Giocatore` varchar(40) NOT NULL,
  `Cronologia` datetime NOT NULL,
  `Oggetto_uno` varchar(50) DEFAULT NULL,
  `Oggetto_due` varchar(50) DEFAULT NULL,
  `Oggetto_tre` varchar(50) DEFAULT NULL,
  `Oggetto_quattro` varchar(50) DEFAULT NULL,
  `Incantesimo_uno` varchar(50) NOT NULL,
  `Incantesimo_due` varchar(50) NOT NULL,
  `Runa_chiave` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `equipaggiamento`
--

INSERT INTO `equipaggiamento` (`Giocatore`, `Cronologia`, `Oggetto_uno`, `Oggetto_due`, `Oggetto_tre`, `Oggetto_quattro`, `Incantesimo_uno`, `Incantesimo_due`, `Runa_chiave`) VALUES
('Ayrok', '2018-04-01 13:32:00', 'Calzari del ninja', 'Lama sanguigna', NULL, NULL, 'Flash', 'Barriera', 'Condottiero'),
('Ayrok', '2018-04-18 15:14:31', 'Calzari di mercurio', 'Frammento d\'infinito', 'Orgoglio di Randuin', 'Lama sanguigna', 'Flash', 'Guarigione', 'Frenesia'),
('Ayrok', '2018-04-19 11:09:24', 'Stivali della rapidità', 'Maschera dell\'abisso', NULL, NULL, 'Flash', ' Teletrasporto', 'Scatto del razziatore'),
('Ayrok', '2018-04-20 22:43:43', 'Calzari del ninja', 'Scettro di cristallo di Rylai', NULL, NULL, 'Flash', 'Ustione', 'Forza delle ere'),
('CanonStylus', '2018-03-19 13:14:41', 'Gambali del berserker', 'Mantello del Sole', 'Orgoglio di Randuin', 'Fulcro dei geli', 'Flash', 'Sfinimento', 'Forza delle ere'),
('CanonStylus', '2018-04-03 10:23:12', 'Calzari di mercurio', 'La Bramasangue', 'Frammento d\'infinito', NULL, 'Barriera', 'Flash', 'Legame di pietra'),
('CanonStylus', '2018-05-30 17:16:08', 'Calzari del ninja', 'Frammento d\'infinito', 'Lama sanguigna', 'Dente di Nashor', 'Flash', 'Guarigione', 'Scatto del razziatore'),
('CanonStylus', '2018-05-31 15:11:43', 'Stivali della rapidità', 'Lastrapietra del gargoyle', 'Corazza dell\'uomo morto', NULL, 'Flash', 'Punizione', 'Presa dell\'immortale'),
('CrazyBirraiol', '2018-03-16 17:46:16', 'Calzari di mercurio', 'Copricapo di Wooglet', 'Scettro di cristallo di Rylai', NULL, 'Flash', 'Barriera', 'Frenesia'),
('CrazyBirraiol', '2018-04-29 21:29:30', 'Stivali della rapidità', 'Copricapo di Wooglet', 'Scettro di cristallo di Rylai', NULL, 'Flash', 'Barriera', 'Sentenza del tuono'),
('CrazyBirraiol', '2018-04-30 15:41:11', 'Calzari di mercurio', 'Scettro di cristallo di Rylai', 'Maschera dell\'abisso', 'Maschera dell\'abisso', 'Flash', 'Ustione', 'Tocco della morte'),
('CrazyBirraiol', '2018-05-01 13:19:29', 'Calzari del ninja', 'Copricapo di Wooglet', 'Fulcro dei geli', 'Mantello del Sole', 'Flash', 'Punizione', 'Legame di pietra'),
('DarkVo0doo', '2018-04-01 22:41:24', 'Calzari del ninja', 'Lama sanguigna', NULL, NULL, 'Flash', 'Guarigione', 'Frenesia'),
('DarkVo0doo', '2018-04-02 08:50:00', 'Calzari del ninja', 'Frammento d\'infinito', 'La Bramasangue', NULL, 'Flash', 'Guarigione', 'Frenesia'),
('DarkVo0doo', '2018-04-13 15:37:41', 'Calzari di mercurio', 'Lama sanguigna', 'Frammento d\'infinito', 'Corazza dell\'uomo morto', 'Flash', 'Barriera', 'Forza delle ere'),
('DarkVo0doo', '2018-04-16 10:24:19', 'Stivali della rapidità', 'Lama sanguigna', 'Frammento d\'infinito', 'Fulcro dei geli', 'Flash', 'Guarigione', 'Forza delle ere'),
('Deumion', '2018-02-08 15:20:08', 'Calzari del ninja', 'Mantello del Sole', 'Fulcro dei geli', 'Medaglione dei Solari di ferro', 'Flash', 'Sfinimento', 'Forza delle ere'),
('Deumion', '2018-04-22 08:50:14', 'Calzari di mercurio', 'Copricapo di Wooglet', 'Dente di Nashor', 'Legamagia', 'Flash', ' Teletrasporto', 'Tocco della morte'),
('Deumion', '2018-04-23 15:19:01', 'Calzari di mercurio', 'Maschera dell\'abisso', 'Legamagia', NULL, 'Flash', 'Barriera', 'Tocco della morte'),
('Deumion', '2018-04-24 17:12:24', 'Gambali del berserker', 'Lastrapietra del gargoyle', 'Mantello del Sole', NULL, 'Flash', 'Sfinimento', 'Presa dell\'immortale'),
('dracos777', '2018-03-22 17:47:12', 'Calzari di mercurio', 'Medaglione dei Solari di ferro', 'Maschera dell\'abisso', 'Maschera dell\'abisso', 'Flash', 'Ustione', 'Tocco della morte'),
('dracos777', '2018-05-06 13:37:09', 'Gambali del berserker', 'Corazza dell\'uomo morto', 'Mantello del Sole', 'Orgoglio di Randuin', 'Flash', 'Sfinimento', 'Legame di pietra'),
('dracos777', '2018-05-07 09:22:10', 'Calzari del ninja', 'Dente di Nashor', NULL, NULL, 'Flash', ' Spettralità', 'Tocco della morte'),
('dracos777', '2018-05-08 17:25:22', 'Gambali del berserker', 'Copricapo di Wooglet', 'Orgoglio di Randuin', 'Maschera dell\'abisso', 'Flash', 'Sfinimento', 'Sentenza del tuono'),
('Felix889', '2018-05-01 13:48:09', 'Calzari di mercurio', 'Copricapo di Wooglet', 'Maschera dell\'abisso', NULL, 'Flash', ' Spettralità', 'Tocco della morte'),
('Felix889', '2018-05-02 22:36:17', 'Calzari di mercurio', 'La Bramasangue', NULL, NULL, 'Flash', 'Guarigione', 'Frenesia'),
('Felix889', '2018-05-03 23:37:18', 'Calzari del ninja', 'Idra famelica', NULL, NULL, 'Flash', 'Ustione', 'Sentenza del tuono'),
('Felix889', '2018-05-04 17:27:32', 'Stivali della rapidità', 'La Bramasangue', 'Idra famelica', 'Elmo adattivo', 'Flash', ' Spettralità', 'Sentenza del tuono'),
('Hiken96', '2018-04-12 16:59:35', 'Calzari del ninja', 'Frammento d\'infinito', 'Idra famelica', NULL, 'Flash', ' Teletrasporto', 'Scatto del razziatore'),
('Hiken96', '2018-04-14 11:35:12', 'Stivali della rapidità', 'Frammento d\'infinito', NULL, NULL, 'Flash', 'Ustione', 'Forza delle ere'),
('Hiken96', '2018-05-05 12:50:16', 'Copricapo di Wooglet', 'Maschera dell\'abisso', 'Calzari di mercurio', NULL, 'Sfinimento', 'Flash', 'Sentenza del tuono'),
('Hiken96', '2018-05-12 10:26:27', 'Calzari del ninja', 'Frammento d\'infinito', 'Idra famelica', 'Corazza dell\'uomo morto', 'Ustione', 'Flash', 'Frenesia'),
('howIrain', '2018-04-12 16:46:30', 'Calzari del ninja', 'Legamagia', NULL, NULL, 'Flash', 'Sfinimento', 'Benedizione del cantore'),
('howIrain', '2018-04-13 11:23:15', 'Gambali del berserker', 'Scettro di cristallo di Rylai', 'Velo della Banshee', 'Corazza dell\'uomo morto', 'Flash', 'Sfinimento', 'Benedizione del cantore'),
('howIrain', '2018-05-01 12:29:00', 'Calzari di mercurio', 'Mantello del Sole', 'Fulcro dei geli', NULL, 'Flash', 'Sfinimento', 'Legame di pietra'),
('howIrain', '2018-05-02 11:10:19', 'Stivali della rapidità', 'Elmo adattivo', NULL, NULL, 'Flash', 'Sfinimento', 'Benedizione del cantore'),
('LaMaggica', '2018-04-05 13:24:18', 'Calzari del ninja', 'Copricapo di Wooglet', 'Dente di Nashor', 'Legamagia', 'Flash', 'Punizione', 'Scatto del razziatore'),
('LaMaggica', '2018-04-05 16:33:24', 'Calzari del ninja', 'Copricapo di Wooglet', 'Maschera dell\'abisso', NULL, 'Flash', ' Teletrasporto', 'Scatto del razziatore'),
('LaMaggica', '2018-04-20 13:22:36', 'Calzari del ninja', 'La Bramasangue', 'Lama sanguigna', 'Orgoglio di Randuin', 'Flash', 'Punizione', 'Sentenza del tuono'),
('LaMaggica', '2018-04-30 13:00:20', 'Calzari del ninja', 'La Bramasangue', NULL, NULL, 'Flash', 'Guarigione', 'Scatto del razziatore'),
('Mario889', '2018-04-03 13:51:18', 'Calzari di mercurio', 'La Bramasangue', 'Lama sanguigna', NULL, 'Flash', ' Teletrasporto', 'Frenesia'),
('Mario889', '2018-04-11 11:18:18', 'Stivali della rapidità', 'Copricapo di Wooglet', 'Scettro di cristallo di Rylai', 'Maschera dell\'abisso', 'Flash', 'Ustione', 'Tocco della morte'),
('Mario889', '2018-05-30 21:29:00', 'Calzari del ninja', 'Lama sanguigna', NULL, NULL, 'Flash', ' Teletrasporto', 'Frenesia'),
('Mario889', '2018-05-31 11:18:13', 'Calzari di mercurio', 'Fulcro dei geli', NULL, NULL, 'Flash', 'Ustione', 'Frenesia'),
('Master Shuppets', '2018-02-09 13:25:34', 'Gambali del berserker', 'Elmo adattivo', 'Medaglione dei Solari di ferro', NULL, 'Flash', 'Sfinimento', 'Benedizione del cantore'),
('Master Shuppets', '2018-04-26 15:29:42', 'Calzari di mercurio', 'Corazza dell\'uomo morto', 'Medaglione dei Solari di ferro', 'Orgoglio di Randuin', 'Flash', 'Sfinimento', 'Legame di pietra'),
('Master Shuppets', '2018-04-30 17:30:00', 'Calzari del ninja', 'Orgoglio di Randuin', 'Mantello del Sole', NULL, 'Flash', 'Sfinimento', 'Legame di pietra'),
('Master Shuppets', '2018-05-01 09:30:11', 'Calzari di mercurio', 'Velo della Banshee', 'Legamagia', NULL, 'Flash', 'Sfinimento', 'Benedizione del cantore'),
('MirrorUp', '2018-03-07 15:23:21', 'Stivali della rapidità', 'La Bramasangue', 'Lama sanguigna', 'Medaglione dei Solari di ferro', ' Teletrasporto', 'Flash', 'Sentenza del tuono'),
('MirrorUp', '2018-04-28 15:32:29', 'Gambali del berserker', 'Mantello del Sole', NULL, NULL, 'Flash', 'Sfinimento', 'Legame di pietra'),
('MirrorUp', '2018-04-30 10:14:21', 'Calzari di mercurio', 'La Bramasangue', 'Idra famelica', NULL, 'Flash', 'Ustione', 'Frenesia'),
('MirrorUp', '2018-05-04 22:35:16', 'Calzari di mercurio', 'Lastrapietra del gargoyle', 'Corazza dell\'uomo morto', 'Orgoglio di Randuin', 'Flash', 'Punizione', 'Legame di pietra'),
('Oh My Darph', '2018-05-13 14:23:08', 'Calzari del ninja', 'Lama sanguigna', 'Frammento d\'infinito', 'Mantello del Sole', 'Flash', 'Guarigione', 'Presa dell\'immortale'),
('Oh My Darph', '2018-05-14 11:21:15', 'Calzari di mercurio', 'Dente di Nashor', NULL, NULL, 'Flash', 'Sfinimento', 'Tocco della morte'),
('Oh My Darph', '2018-05-15 21:47:04', 'Calzari di mercurio', 'Copricapo di Wooglet', 'Dente di Nashor', NULL, 'Flash', 'Guarigione', 'Tocco della morte'),
('Oh My Darph', '2018-05-16 16:23:32', 'Calzari di mercurio', 'Frammento d\'infinito', 'La Bramasangue', 'Lama sanguigna', 'Flash', 'Guarigione', 'Condottiero'),
('xTigerMaster', '2018-02-15 20:14:15', 'Gambali del berserker', 'Copricapo di Wooglet', 'Scettro di cristallo di Rylai', NULL, 'Flash', ' Teletrasporto', 'Scatto del razziatore'),
('xTigerMaster', '2018-03-15 20:48:18', 'Calzari di mercurio', 'Corazza dell\'uomo morto', 'Mantello del Sole', 'Dente di Nashor', ' Teletrasporto', 'Flash', 'Condottiero'),
('xTigerMaster', '2018-03-20 21:27:07', 'Stivali della rapidità', 'Elmo adattivo', 'Idra famelica', 'La Bramasangue', ' Teletrasporto', 'Flash', 'Scatto del razziatore'),
('xTigerMaster', '2018-04-18 09:48:25', 'Calzari di mercurio', 'Frammento d\'infinito', 'La Bramasangue', 'Lama sanguigna', 'Flash', 'Guarigione', 'Condottiero'),
('xXDarkXx', '2018-04-25 13:31:19', 'Calzari del ninja', 'La Bramasangue', NULL, NULL, 'Flash', ' Teletrasporto', 'Frenesia'),
('xXDarkXx', '2018-04-26 10:46:07', 'Calzari del ninja', 'Idra famelica', NULL, NULL, 'Flash', ' Teletrasporto', NULL),
('xXDarkXx', '2018-04-27 16:34:18', 'Calzari di mercurio', 'Lama sanguigna', 'La Bramasangue', 'Dente di Nashor', 'Flash', 'Guarigione', 'Sentenza del tuono'),
('xXDarkXx', '2018-04-28 20:33:18', 'Stivali della rapidità', 'Maschera dell\'abisso', 'Fulcro dei geli', NULL, 'Flash', 'Punizione', 'Tocco della morte');

-- --------------------------------------------------------

--
-- Struttura della tabella `giocatore`
--

CREATE TABLE `giocatore` (
  `Nome` varchar(40) NOT NULL,
  `Livello_Onore` smallint(6) DEFAULT NULL,
  `Livello` smallint(6) DEFAULT NULL,
  `Data_Iscrizione` date DEFAULT NULL,
  `Club` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `giocatore`
--

INSERT INTO `giocatore` (`Nome`, `Livello_Onore`, `Livello`, `Data_Iscrizione`, `Club`) VALUES
('Ayrok', 2, 13, '2015-03-20', NULL),
('CanonStylus', 3, 37, '2013-05-15', 'Rox Tiger'),
('CrazyBirraiol', 3, 47, '2016-01-26', NULL),
('DarkVo0doo', 4, 56, '2014-08-02', 'Rox Tiger'),
('Deumion', 0, 63, '2015-04-16', 'Counter Logic Game'),
('dracos777', 4, 75, '2011-10-06', NULL),
('Felix889', 5, 100, '2015-10-02', 'H2K'),
('Hiken96', 5, 34, '2014-08-29', NULL),
('howIrain', 4, 65, '2010-09-21', 'Counter Logic Game'),
('LaMaggica', 5, 59, '2015-06-20', 'Cloud9'),
('Mario889', 5, 76, '2010-04-21', 'H2K'),
('Master Shuppets', 1, 90, '2016-11-23', 'Cloud9'),
('MirrorUp', 5, 111, '2010-12-05', 'Counter Logic Game'),
('Oh My Darph', 5, 53, '2014-12-28', NULL),
('xTigerMaster', 5, 60, '2014-05-24', 'Rox Tiger'),
('xXDarkXx', 1, 15, '2018-02-18', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `incantesimo`
--

CREATE TABLE `incantesimo` (
  `Nome` varchar(50) NOT NULL,
  `Descrizione` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `incantesimo`
--

INSERT INTO `incantesimo` (`Nome`, `Descrizione`) VALUES
(' Chiarezza', 'Ripristina il 50% del mana massimo del tuo campione. Ripristina anche il 25% del mana massimo dei tuoi alleati.'),
(' Purificazione', 'Rimuove tutti gli impedimenti (soppressioni e lanci in aria esclusi) e tutti i debuff degli incantesimi dell\'evocatore che affliggono il tuo campione e abbassa la durata di tutti gli impedimenti successivi del 65% per 3 secondi.'),
(' Spettralità', 'Il tuo campione ignora le collisioni e ottiene velocità di movimento in più per 10 secondi. Raggiunge un picco del 28-45% di velocità (in base al livello del campione) di movimento extra dopo aver accelerato per 2 secondi.'),
(' Teletrasporto', 'Dopo 4,5 secondi di canalizzazione, teletrasporta il campione verso una struttura, un minion o un lume degli alleati.'),
('Barriera', 'Protegge il tuo campione per 115-455 danni (in base al livello del campione) per 2 secondi.'),
('Flash', 'Teletrasporta il tuo campione per una breve distanza verso il punto indicato dal tuo cursore.'),
('Guarigione', 'Ripristina 90-345 salute (in base al livello del campione) e conferisce il 30% di velocità di movimento per un secondo a te e al campione alleato bersaglio. L\'effetto è dimezzato per le unità che sono state appena bersaglio dell\'incantesimo dell\'evocatore Guarigione.'),
('Punizione', 'Infligge 390-1000 danni puri (in base al livello del campione) al minion o al mostro bersaglio epico, grande o medio. Ripristina salute in base alla salute massima se usato contro i mostri.'),
('Sfinimento', 'Sfinisce un campione nemico bersaglio, riducendone la velocità di movimento del 30% e i danni inflitti del 40%. La durata dell\'effetto è di 2,5 secondi.'),
('Ustione', 'Dà fuoco al campione nemico bersaglio, infliggendo 80-505 danni puri (in base al livello del campione) in 5 secondi. Fornisce visione del bersaglio e ne riduce gli effetti curativi per tutta la durata dell\'effetto.');

-- --------------------------------------------------------

--
-- Struttura della tabella `informazioni_campione`
--

CREATE TABLE `informazioni_campione` (
  `Campione` varchar(20) NOT NULL,
  `Genere` varchar(40) DEFAULT NULL,
  `Corsia_principale` varchar(40) DEFAULT NULL,
  `Corsia_secondaria` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `informazioni_campione`
--

INSERT INTO `informazioni_campione` (`Campione`, `Genere`, `Corsia_principale`, `Corsia_secondaria`) VALUES
('Aatrox', 'Combattente', 'Superiore', 'Giungla'),
('Ahri', 'Mago', 'Centrale', NULL),
('Akali', 'Assassino', 'Centrale', 'Superiore'),
('Alistar', 'Supporto', 'Inferiore', 'Superiore'),
('Amumu', 'Tank', 'Giungla', NULL),
('Anivia', 'Mago', 'Centrale', NULL),
('Annie', 'Mago', 'Centrale', 'Inferiore'),
('Ashe', 'Tiratore', 'Inferiore', NULL),
('Aurelion Sol', 'Mago', 'Centrale', NULL),
('Azir', 'Mago', 'Centrale', NULL),
('Bard', 'Supporto', 'Inferiore', NULL),
('Blitzcrank', 'Supporto', 'Inferiore', NULL),
('Brand', 'Mago', 'Centrale', 'Inferiore'),
('Braum', 'Supporto', 'Inferiore', NULL),
('Caitlyn', 'Tiratore', 'Inferiore', NULL),
('Camille', 'Combattente', 'Superiore', NULL),
('Draven', 'Tiratore', 'Inferiore', NULL),
('Ekko', 'Mago', 'Centrale', 'Giungla'),
('Ezreal', 'Tiratore', 'Inferiore', 'Centrale'),
('Fiora', 'Combattente', 'Superiore', 'Giungla'),
('Galio', 'Tank', 'Centrale', 'Superiore'),
('Graves', 'Tiratore', 'Giungla', 'Inferiore'),
('Irelia', 'Combattente', 'Superiore', NULL),
('Janna', 'Supporto', 'Inferiore', NULL),
('Jhin', 'Tiratore', 'Inferiore', NULL),
('Kalista', 'Tiratore', 'Inferiore', NULL),
('Kassadin', 'Mago', 'Centrale', NULL),
('Kindred', 'Tiratore', 'Giungla', 'Inferiore'),
('Leona', 'Supporto', 'Inferiore', NULL),
('Lucian', 'Tiratore', 'Inferiore', NULL),
('Master Yi', 'Assassino', 'Giungla', 'Superiore'),
('Morgana', 'Mago', 'Inferiore', 'Centrale'),
('Nami', 'Supporto', 'Inferiore', NULL),
('Nunu', 'Tank', 'Giungla', NULL),
('Olaf', 'Combattente', 'Superiore', 'Giungla'),
('Pantheon', 'Combattente', 'Superiore', 'Giungla'),
('Rakan', 'Supporto', 'Inferiore', 'Centrale'),
('Rengar', 'Assassino', 'Giungla', 'Superiore'),
('Skarner', 'Tank', 'Giungla', NULL),
('Sona', 'Supporto', 'Inferiore', NULL),
('Thresh', 'Supporto', 'Inferiore', NULL),
('Varus', 'Tiratore', 'Inferiore', NULL),
('Vayne', 'Tiratore', 'Inferiore', 'Superiore'),
('Vladimir', 'Mago', 'Centrale', NULL),
('Xayah', 'Tiratore', 'Inferiore', NULL),
('Yasuo', 'Combattente', 'Centrale', 'Superiore'),
('Zed', 'Assassino', 'Centrale', 'Superiore'),
('Zoe', 'Mago', 'Centrale', NULL);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `media_costo_oggetti`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `media_costo_oggetti` (
`Giocatore` varchar(40)
,`Media_costo_oggetti` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `media_maestrie_lega_1`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `media_maestrie_lega_1` (
`Possessore` varchar(40)
,`Media_Maestria` decimal(14,4)
);

-- --------------------------------------------------------

--
-- Struttura della tabella `mossa_campione`
--

CREATE TABLE `mossa_campione` (
  `Nome` varchar(50) NOT NULL,
  `Tasto` char(1) NOT NULL,
  `Descrizione` varchar(500) NOT NULL,
  `Campione` varchar(20) DEFAULT NULL,
  `Danni_Magici` int(11) NOT NULL,
  `Danni_Fisici` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `mossa_campione`
--

INSERT INTO `mossa_campione` (`Nome`, `Tasto`, `Descrizione`, `Campione`, `Danni_Magici`, `Danni_Fisici`) VALUES
(' Benedizione delle maree', 'E', 'Potenzia un campione alleato per una breve durata. Gli attacchi base dell\'alleato infliggono danni magici bonus e rallentano il bersaglio.', 'Nami', 35, 0),
(' Lancio della bendatura', 'Q', 'Amumu lancia una benda appiccicosa a un bersaglio, stordendolo e danneggiandolo mentre si avvicina a esso.', 'Amumu', 80, 0),
(' Testata', 'W', 'Alistar carica il bersaglio con la testa, infliggendo danni e respingendolo.', 'Alistar', 25, 0),
('Agilità superiore', 'R', 'Master Yi si muove con agilità impareggiabile, aumentando temporaneamente il movimento e la velocità d\'attacco e diventando immune agli effetti di rallentamento. Quando l\'effetto è attivo, le uccisioni dei campioni o gli assist aumentano la durata di Agilità superiore. Riduce passivamente la ricarica per le altre abilità quando si effettua un assist o un\'uccisione.', 'Master Yi', 0, 123),
('Altare del custode', 'W', 'Rivela un altare curativo che si potenzia in un breve periodo, per poi sparire dopo che un alleato lo tocca.', 'Bard', 85, 0),
('Aria della perseveranza', 'W', 'Sona suona l\'Aria della perseveranza, producendo melodie protettive che curano lei e un alleato ferito nelle vicinanze. Sona ottiene un\'aura temporanea che conferisce agli alleati colpiti dalla zona uno scudo temporaneo.', 'Sona', 46, 0),
('Artiglio dell\'ombra', 'E', 'Zed e la sua ombra roteano la loro lama, creando un impulso di energia d\'ombra. La rotazione dell\'ombra rallenta.', 'Zed', 0, 45),
('Ascia rotante', 'Q', 'Il prossimo attacco di Draven infligge danni fisici bonus. La sua ascia rimbalza sul bersaglio, volando verso l\'alto. Se Draven la prende, ha automaticamente pronto un altro attacco con Ascia rotante. Draven può avere due Asce rotanti contemporaneamente.', 'Draven', 0, 56),
('Ascia turbinante', 'Q', 'Olaf lancia un\'ascia nel suolo in un punto bersaglio, infliggendo danni ai nemici colpiti lungo il suo percorso e rallentandone il movimento. Se Olaf raccoglie l\'ascia, il tempo di ricarica dell\'abilità è ridotto di 4,5 secondi.', 'Olaf', 0, 87),
('Assalto spirituale', 'R', 'Ahri scatta in avanti e scaglia dardi di essenza, danneggiando i nemici nelle vicinanze. Assalto spirituale può essere lanciato tre volte, prima di entrare in ricarica.', 'Ahri', 100, 0),
('Attacco impetuoso', 'E', 'Graves scatta in avanti, ottenendo un bonus all\'armatura per alcuni secondi. Se Graves scatta verso un campione nemico, ottiene due cariche di Autentica determinazione. Colpire i nemici con attacchi base riduce il tempo di ricarica dell\'abilità e ripristina la resistenza.', 'Graves', 0, 78),
('Attacco repentino', 'Q', 'Fiora si lancia in una direzione e trafigge un nemico nelle vicinanze, infliggendo danni fisici e applicando gli effetti sul colpo.', 'Fiora', 0, 83),
('Attacco temerario', 'E', 'Olaf attacca con così tanta forza che infligge danni puri al suo bersaglio e a sé stesso, recuperando la salute perduta se distrugge il bersaglio.', 'Olaf', 0, 67),
('Bagliore ardente', 'W', 'Lucian spara un proiettile che esplode con uno schema a stella, marchiando i nemici. Attaccando i nemici marchiati Lucian guadagna velocità di movimento.', 'Lucian', 45, 34),
('Barbarie', 'Q', 'Al prossimo attacco Rengar infilza brutalmente il bersaglio infliggendogli danni bonus.', 'Rengar', 0, 80),
('Bolla della nanna', 'E', 'Fa diventare sonnolento il bersaglio, per poi farlo addormentare. La prima fonte di danni che interrompe il sonno è raddoppiata, ma con un limite massimo di danni.', 'Zoe', 65, 0),
('Brivido della caccia', 'R', 'L\'istinto da predatore di Rengar prende il sopravvento, mimetizzandolo e rivelando il campione nemico più vicino entro un ampio raggio intorno a lui. Durante Brivido della caccia, Rengar ottiene velocità di movimento e può balzare sul nemico individuato per un colpo critico garantito, anche se non è nell\'erba alta.', 'Rengar', 0, 110),
('Campo statico', 'R', 'Passivamente dei fulmini infliggono danni a dei nemici a caso nelle vicinanze. In più, Blitzcrank può attivare questa abilità per infliggere danni ai nemici circostanti e silenziarli per 0,5 secondi, ma facendo questo rimuove la passiva di Campo statico finché non torna di nuovo disponibile.', 'Blitzcrank', 90, 0),
('Capriola', 'Q', 'Vayne fa una capriola, cercando di piazzare il suo prossimo colpo con precisione. Il suo prossimo attacco infligge un colpo critico.', 'Vayne', 0, 0),
('Cataclisma di fuoco', 'R', 'Brand scatena un devastante fiume di fuoco, che infligge danni magici a ogni rimbalzo, fino a un massimo di 5 rimbalzi. I rimbalzi danno la priorità al raggiungimento del massimo delle cariche di Fiammata sui campioni. Se il bersaglio è in fiamme, Cataclisma di fuoco lo rallenta brevemente.', 'Brand', 130, 0),
('Catena della corruzione', 'R', 'Varus scaglia un dannoso tentacolo di corruzione che immobilizza il primo campione nemico colpito e quindi si trasmette verso i campioni non infetti nelle vicinanze, immobilizzandoli a contatto.', 'Varus', 0, 136),
('Catene spirituali', 'R', 'Aggancia catene d\'energia sui campioni nemici nelle vicinanze, infliggendo danni iniziali e rallentandone la velocità di movimento, poi dopo qualche secondo, riecheggia il dolore, stordendo tutti i nemici rimasti vicini a Morgana.', 'Morgana', 89, 0),
('Catturare il pubblico', 'E', 'Jhin piazza una trappola di loto invisibile che sboccia quando viene calpestata. Rallenta i nemici nelle vicinanze per poi infliggere danni con un\'esplosione di petali taglienti. ', 'Jhin', 23, 56),
('Chiamata alla ribalta', 'R', 'Jhin canalizza, trasformando Sussurro in un maestoso cannone da spalla. È in grado di sparare 4 colpi potenziati con grande gittata, capaci di perforare minion e mostri, ma che si fermano al primo campione colpito. Sussurro menoma i nemici colpiti, rallentandoli e infliggendo danni da esecuzione. Il quarto colpo è perfetto e ha una potenza epica che garantisce il colpo critico.', 'Jhin', 0, 113),
('Chiamata del fato', 'R', 'Kalista teletrasporta da sé il suo compagno di Patto, che ottiene l\'abilità di scattare verso una posizione, respingendo i campioni nemici.', 'Kalista', 0, 112),
('Collera', 'E', 'Riduce permanentemente i danni fisici che Amumu subirebbe. Amumu può scatenare la sua rabbia infliggendo danni a tutti i nemici circostanti. Ogni volta che Amumu viene colpito, il tempo di ricarica di Collera si riduce di 0,5 secondi.', 'Amumu', 60, 0),
('Colpi feroci', 'W', 'Olaf ha la velocità d\'attacco aumentata. Il suo rubavita aumenta e viene curato di più da tutte le fonti, in base alla salute mancante.', 'Olaf', 0, 44),
('Colpo alfa', 'Q', 'Master Yi si teletrasporta in giro per il campo di battaglia ad altissima velocità, infliggendo danni a più unità sul suo percorso senza essere bersagliabile. Colpo alfa può infliggere colpi critici e infligge danni bonus a minion e mostri. Gli attacchi base riducono la ricarica di Colpo alfa.', 'Master Yi', 0, 76),
('Colpo del falco', 'E', 'Ashe invia il suo spirito del falco in ricognizione ovunque sulla mappa.\r\nRivela il terreno volando verso la posizione bersaglio in un qualunque punto della mappa. Conferisce visione per 5 secondi. Ashe può immagazzinare fino a 2 cariche di Colpo del falco.', 'Ashe', 0, 10),
('Colpo della lancia', 'Q', 'Pantheon scaglia la sua lancia all\'avversario, infliggendo danni.', 'Pantheon', 0, 65),
('Colpo di bola', 'E', 'Rengar lancia una bola, rallentando il primo bersaglio colpito per un breve periodo.', 'Rengar', 30, 60),
('Colpo di taglio', 'E', 'Scatta attraverso un\'unità, infliggendo danni magici crescenti ad ogni lancio.', 'Yasuo', 55, 0),
('Colpo gelato', 'E', 'Nunu lancia una palla di ghiaccio a un\'unità nemica, infliggendo danni e rallentando temporaneamente la sua velocità di movimento e d\'attacco.', 'Nunu', 45, 0),
('Colpo mistico', 'Q', 'Ezreal spara un forte dardo di energia che riduce i suoi tempi di ricarica di 1,5 secondi se colpisce un\'unità nemica.', 'Ezreal', 0, 65),
('Colpo perfetto', 'R', 'Caitlyn prende tempo per indirizzare il colpo perfetto, infliggendo danni ingenti a un bersaglio, a enorme distanza. I campioni nemici possono intercettare il proiettile per il loro alleato.', 'Caitlyn', 20, 80),
('Cometa leggendaria', 'E', 'La velocità di Aurelion Sol aumenta mentre si muove lungo la stessa direzione e può coprire in volo lunghe distanze.', 'Aurelion Sol', 50, 0),
('Concentrazione dell\'esploratrice', 'Q', 'Ashe accumula Concentrazione attaccando. Quando ha la Concentrazione al massimo, Ashe può lanciare Concentrazione dell\'esploratrice per consumare tutte le cariche di Concentrazione, aumentando temporaneamente la sua velocità d\'attacco e trasformando il suo attacco base in una potente sventagliata per tutta la durata.', 'Ashe', 0, 75),
('Condanna', 'E', 'Vayne estrae la sua balestra pesante dalla schiena, e spara un grosso dardo al suo bersaglio, infliggendo danni e respingendolo. Se collide con un muro, il suo avversario è impalato, subisce danni bonus ed è stordito.', 'Vayne', 0, 60),
('Condanna a morte', 'Q', 'Thresh incatena un nemico e lo tira verso di lui. Attivare l\'abilità una seconda volta porta Thresh verso il nemico.', 'Thresh', 70, 0),
('Conflagrazione', 'E', 'Brand lancia una potente scarica contro il bersaglio, infliggendo danni magici. Se il bersaglio è in fiamme, Conflagrazione si trasmette ai nemici nelle vicinanze.', 'Brand', 60, 0),
('Consumazione', 'Q', 'Nunu comanda allo yeti di azzannare un mostro o un minion bersaglio, infliggendo ingenti danni e curandosi.', 'Nunu', 67, 0),
('Contrattacco', 'W', 'Fiora para tutti i danni e gli impedimenti per un breve periodo, poi colpisce in una direzione. Il colpo rallenta il primo campione nemico colpito. Se Fiora ha parato tramite l\'abilità un effetto immobilizzante, il campione viene stordito.', 'Fiora', 0, 76),
('Convergenza parallela', 'W', 'Ekko divide la linea temporale, creando un\'anomalia dopo pochi secondi che rallenta i nemici al suo interno. Se Ekko entra nell\'anomalia, ottiene uno scudo e attiva una detonazione, stordendo i nemici e sospendendoli nel tempo.', 'Ekko', 67, 0),
('Cortina fumogena', 'W', 'Graves spara un colpo fumogeno, creando una nuvola di fumo che riduce il raggio visivo. I nemici colpiti dall\'impatto iniziale subiscono danni magici e hanno la velocità di movimento ridotta per un breve periodo.', 'Graves', 23, 20),
('Crescendo', 'R', 'Sona suona il suo accordo supremo, stordendo i campioni nemici e obbligandoli a ballare e a subire danni magici. Ogni livello riduce la ricarica base delle abilità base di Sona.', 'Sona', 140, 0),
('Cristallizzazione', 'W', 'Anivia condensa l\'umidità dell\'aria in un impenetrabile muro di ghiaccio, che blocca ogni movimento. Il muro si scioglie dopo un breve periodo di tempo.', 'Anivia', 75, 0),
('Cronodisco', 'Q', 'Ekko lancia una granata temporale che esplode, creando un campo di distorsione temporale se colpisce un campione nemico, rallentando e danneggiando tutte le unità nemiche al suo interno. Dopo un periodo di tempo la granata si riavvolge e torna da Ekko, infliggendo danni lungo il percorso.', 'Ekko', 97, 0),
('Danni collaterali', 'R', 'Graves lancia un colpo esplosivo che infligge danni ingenti al primo campione che colpisce. Dopo aver colpito un campione o aver raggiunto la fine della portata, il colpo esplode causando danni in un\'area conica.', 'Graves', 0, 115),
('Danza delle frecce', 'Q', 'Kindred rotola e spara fino a tre frecce ai bersagli nelle vicinanze.', 'Kindred', 0, 87),
('Danza delle ombre', 'R', 'Akali si muove nell\'ombra per colpire rapidamente attraverso il bersaglio, infliggendo danni e consumando una carica di Essenza dell\'ombra. Akali ricarica Essenza dell\'ombra a intervalli di tempo regolari, fino a un massimo di 3 cariche.', 'Akali', 80, 70),
('Danza di guerra', 'E', 'Vola da un campione alleato, conferendogli uno scudo. Può essere rilanciata gratuitamente entro un breve periodo.', 'Rakan', 0, 0),
('Danza sprezzante', 'W', 'Irelia carica un colpo che infligge più danni. Maggiore è la carica, maggiori sono i danni. Irelia subisce danni ridotti durante la carica.', 'Irelia', 21, 23),
('Dardi d\'argento', 'W', 'Vayne usa come punte dei suoi dardi un raro metallo, tossico per tutte le creature maligne. Il terzo attacco o abilità consecutivo contro lo stesso bersaglio infligge una percentuale della salute massima del bersaglio come danni puri bonus (massimo: 200 danni contro i mostri).', 'Vayne', 30, 30),
('Destino immobile', 'R', 'Bard lancia una scarica di energia spirituale nella posizione bersaglio, facendo entrare tutte le unità e le torri in stasi per un breve periodo.', 'Bard', 140, 0),
('Determinazione', 'E', 'Lucian scatta rapidamente per una breve distanza. Gli attacchi di Pistolero illuminato riducono la ricarica di Determinazione.', 'Lucian', 0, 0),
('Dietro di me', 'W', 'Braum salta verso un campione o un minion alleato. Quando arriva, lui e l\'alleato ottengono armatura e resistenza magica per qualche secondo.', 'Braum', 0, 10),
('Disintegrazione', 'Q', 'Annie scaglia una palla di fuoco intrisa di mana, infliggendo danni e rimborsando il costo in mana se distrugge il bersaglio.', 'Annie', 70, 0),
('Disperazione', 'W', 'Sopraffatti dall\'angoscia, i nemici nelle vicinanze perdono una percentuale della loro salute massima ogni secondo e vedono ripristinate le loro maledizioni.', 'Amumu', 75, 0),
('Doppia daga', 'Q', 'Xayah lancia due daghe che infliggono danni e lasciano piume che può richiamare.', 'Xayah', 0, 80),
('Duetto impeccabile', 'E', 'Irelia lancia due lame che convergono una sull\'altra. I nemici colpiti vengono danneggiati, storditi e marchiati.', 'Irelia', 0, 75),
('Eclissi', 'W', 'Leona alza lo scudo per guadagnare armatura e resistenza magica. Al termine della durata, se ci sono dei nemici nelle vicinanze, Leona gli infligge danni magici e prolunga l\'effetto.', 'Leona', 89, 0),
('Emopiaga', 'R', 'Vladimir infetta un\'area con una piaga virulenta. I nemici colpiti subiscono danni aumentati per la durata. Dopo alcuni secondi, Emopiaga infligge danni magici ai nemici infettati e cura Vladimir per ogni campione nemico colpito.', 'Vladimir', 138, 0),
('Entrata dell\'eroe', 'R', 'Galio conferisce riduzione danni a un alleato. Dopo un breve lasso di tempo Galio colpisce la posizione originale dell\'alleato, lanciando in aria i nemici nelle vicinanze.', 'Galio', 110, 0),
('Esoscheletro cristallino', 'W', 'Skarner ottiene uno scudo e ha la velocità di movimento aumentata finché lo scudo persiste.', 'Skarner', 0, 65),
('Espansione celestiale', 'W', 'Aurelion Sol espande ancora di più le sue stelle, aumentando i danni.', 'Aurelion Sol', 45, 0),
('Evocazione: Tibbers', 'R', 'Annie ordina al suo orso Tibbers di prender vita, infliggendo danni a tutte le unità nell\'area. Tibbers può attaccare e brucia anche i nemici che stanno vicino a lui.', 'Annie', 120, 0),
('Falciata tattica', 'W', 'Camille colpisce un\'area conica dopo un periodo di tempo, infliggendo danni. I nemici nella metà esterna vengono rallentati e subiscono danni aggiuntivi, curando Camille.', 'Camille', 0, 75),
('Faretra del flagello', 'W', 'Passiva: gli attacchi base di Varus infliggono danni magici bonus e applicano Flagello. Le altre abilità di Varus fanno esplodere Flagello, infliggendo danni magici in base alla salute massima del bersaglio. Attiva: Varus potenzia la sua prossima Freccia penetrante.', 'Varus', 0, 45),
('Fatti da parte', 'E', 'Draven lancia le sue asce, infliggendo danni fisici ai bersagli colpiti e sbalzandoli sui lati. I bersagli colpiti vengono rallentati.', 'Draven', 0, 23),
('Fendenti assassini', 'E', 'Pantheon si concentra e lancia 3 colpi veloci nell\'area davanti a sé, infliggendo danni a tutti i nemici. Pantheon diventa inoltre cosciente dei punti vitali del nemico, permettendogli di fare danni critici ai nemici sotto il 15% di salute.', 'Pantheon', 0, 70),
('Fiamma solare', 'R', 'Leona invoca un raggio di luce solare, che infligge danni ai nemici nell\'area. I nemici nel centro dell\'area sono storditi, mentre i nemici nell\'area esterna sono rallentati. In seguito, la spada di Leona si carica con il potere del sole e infligge danni magici bonus per alcuni attacchi.', 'Leona', 115, 0),
('Fine della corsa', 'Q', 'Graves spara un proiettile esplosivo che scoppia dopo 2 secondi, o 0,2 secondi se colpisce il terreno.', 'Graves', 0, 84),
('Florilegio letale', 'W', 'Jhin brandisce il suo bastone, sparando un singolo colpo con una gittata incredibile. Perfora minion e mostri, ma si ferma al primo campione. Se il bersaglio era stato colpito di recente dagli alleati di Jhin, dalle trappole di loto o dagli attacchi base, viene immobilizzato.', 'Jhin', 45, 0),
('Flusso e riflusso', 'W', 'Emette un getto d\'acqua che rimbalza tra campioni alleati e nemici, curando gli alleati e danneggiando i nemici.', 'Nami', 55, 0),
('Flusso essenziale', 'W', 'Ezreal spara un\'onda fluttuante di energia, che infligge danni magici ai campioni nemici. Nel mentre, la velocità d\'attacco dei campioni alleati aumenta.', 'Ezreal', 46, 0),
('Frattura del cristallo', 'E', 'Skarner evoca una scarica di Energia del cristallo che infligge danni ai nemici colpiti e li rallenta. Gli attacchi base contro questi nemici entro una breve finestra di tempo li stordiscono.', 'Skarner', 30, 20),
('Frattura glaciale', 'R', 'Braum colpisce il terreno, lanciando in aria i nemici nelle vicinanze in una linea davanti a lui. Lungo la linea rimane una frattura che rallenta i nemici.', 'Braum', 0, 100),
('Frattura spazio temporale', 'R', 'Kassadin si teletrasporta in una posizione vicina, infliggendo danni alle unità nemiche nelle vicinanze. Usare più Fratture spazio temporali in un breve periodo di tempo costa più mana, ma permette di infliggere più danni.', 'Kassadin', 114, 0),
('Frattura temporale', 'R', 'Ekko distrugge la sua linea temporale, diventando non bersagliabile e tornando indietro nel tempo in un momento più favorevole. Ritorna dove si trovava pochi secondi prima, guarisce di una percentuale dei danni ricevuti in quel periodo e infligge danni ingenti ai nemici nella sua zona di arrivo.', 'Ekko', 148, 0),
('Freccia di cristallo incantata', 'R', 'Ashe scaglia un proiettile di ghiaccio in linea retta. Se incontra un campione nemico, infligge danni e lo stordisce. Lo stordimento aumenta con la distanza coperta dal proiettile. Inoltre, le unità vicine al nemico subiscono danni e vengono rallentate.', 'Ashe', 0, 110),
('Freccia penetrante', 'Q', 'Varus si prepara e poi spara un colpo di incredibile potenza. Più tempo impiega a preparare il colpo e più guadagna gittata e danni.', 'Varus', 0, 80),
('Frenesia del Lupo', 'W', 'Il Lupo si infuria e attacca i nemici intorno a lui.', 'Kindred', 0, 60),
('Fuoco ardente', 'Q', 'Brand lancia una palla di fuoco che infligge danni magici. Se il bersaglio è in fiamme, Fuoco ardente lo stordisce per 1,5 secondi.', 'Brand', 65, 0),
('Furto magico', 'W', 'Zoe può raccogliere ciò che resta degli incantesimi dell\'evocatore e dei lanci degli oggetti attivi e lanciarli nuovamente. Quando lancia un incantesimo dell\'evocatore ottiene 3 proiettili che vengono sparati al bersaglio più vicino.', 'Zoe', 0, 0),
('Gioco di lama', 'E', 'Fiora ha la velocità d\'attacco aumentata per i prossimi due attacchi. Il primo attacco rallenta il bersaglio, il secondo mette a segno un colpo critico.', 'Fiora', 0, 72),
('Globo dell\'inganno', 'Q', 'Ahri lancia e riprende il suo globo, infliggendo danni magici all\'andata e danni puri al ritorno. Dopo che Ahri ha messo a segno vari colpi con le abilità, il suo Globo successivo ripristina la sua salute.', 'Ahri', 85, 0),
('Grande meteora', 'R', 'Pantheon si prepara per poi lanciarsi in aria verso un bersaglio, colpendo tutte le unità nemiche nell\'area. I nemici più vicini all\'area d\'impatto subiscono più danni.', 'Pantheon', 45, 45),
('Impalamento', 'R', 'Skarner sopprime il campione nemico e gli infligge danni. Durante questo periodo, Skarner può muoversi liberamente e trascinare l\'impotente vittima con sé. Quando l\'effetto finisce, il bersaglio subisce danni addizionali.', 'Skarner', 0, 145),
('Impeto della lama', 'Q', 'Irelia scatta in avanti per colpire il suo bersaglio, curandosi. Se il bersaglio è marchiato o muore per Impeto della lama, la ricarica si azzera.', 'Irelia', 0, 56),
('Incantalame', 'E', 'Xayah richiama a sé le piume che ha lasciato, infliggendo danni e immobilizzando i nemici.', 'Xayah', 40, 45),
('Incenerimento', 'W', 'Annie lancia un cono di fuoco rovente, infliggendo danni a tutti i nemici nell\'area.', 'Annie', 80, 0),
('Indistruttibile', 'E', 'Braum alza il suo scudo in una direzione per alcuni secondi, intercettando e distruggendo tutti i proiettili che lo colpiscono. Nega tutti i danni del primo attacco e riduce quelli degli attacchi successivi provenienti da questa direzione.', 'Braum', 0, 15),
('Ingresso trionfale', 'W', 'Scatta verso una posizione, lanciando in aria i nemici all\'arrivo.', 'Rakan', 50, 0),
('Inno al valore', 'Q', 'Sona suona l\'Inno al valore, sparando colpi sonori che infliggono danni magici a due nemici nelle vicinanze, con priorità a campioni e mostri. Sona ottiene un\'aura temporanea che conferisce agli alleati colpiti dalla zona danni bonus per il prossimo attacco contro i nemici.', 'Sona', 75, 0),
('Insegne di Zeonia', 'W', 'Pantheon balza sul nemico e lo colpisce con il suo scudo, stordendolo. Dopo aver finito l\'attacco, Pantheon prepara il suo scudo per bloccare il prossimo attacco.', 'Pantheon', 30, 0),
('Ipervelocità', 'W', 'Blitzcrank si sovraccarica per ottenere molta velocità di movimento e di attacco. Al termine dell\'effetto, rallenta temporaneamente.', 'Blitzcrank', 10, 0),
('Ispirazione improvvisa', 'Q', 'Jhin spara un bossolo magico a un nemico. Può colpire fino a quattro bersagli e aumenta i suoi danni ogni volta che uccide.', 'Jhin', 0, 78),
('La scatola', 'R', 'Una prigione che rallenta e infligge danni se viene oltrepassata.', 'Thresh', 95, 0),
('Lacerazione', 'E', 'Gli attacchi impalano i bersagli con le lance. Attiva per strappare le lance, rallentando e infliggendo danni crescenti.', 'Kalista', 25, 45),
('Lago di sangue', 'W', 'Vladimir si scioglie in una pozza di sangue, diventando non bersagliabile per 2 secondi. In più, i nemici sulla pozza sono rallentati e Vladimir ne assorbe la vita.', 'Vladimir', 60, 0),
('Lama degli inferi', 'W', 'Passiva: gli attacchi base di Kassadin infliggono danni magici bonus. Attiva: il prossimo attacco base di Kassadin infligge molti danni magici bonus e fa recuperare mana.', 'Kassadin', 75, 0),
('Lama dell\'avanguardia', 'R', 'Irelia lancia una gran quantità di lame che esplodono verso l\'esterno dopo aver colpito un campione nemico. I nemici colpiti dalle lame vengono danneggiati e marchiati. Dopodiché, le lame formano un muro che danneggia, rallenta e disarma i nemici che lo attraversano.', 'Irelia', 0, 114),
('Lama dello zenith', 'E', 'Leona proietta un\'immagine solare della sua spada, che infligge danni magici a tutti i nemici in una linea. Quando l\'immagine svanisce, l\'ultimo campione nemico colpito viene brevemente immobilizzato e Leona gli si lancia addosso.', 'Leona', 56, 0),
('Lame del tormento', 'E', 'Aatrox scatena tutta la potenza della sua lama, infliggendo danni ai nemici colpiti e rallentandoli.', 'Aatrox', 40, 10),
('Legame cosmico', 'Q', 'Bard spara un proiettile che rallenta il primo nemico colpito, per poi proseguire. Se colpisce un muro, stordisce il primo bersaglio. Se colpisce un altro nemico, stordisce entrambi i bersagli.', 'Bard', 75, 0),
('Legame oscuro', 'Q', 'Morgana rilascia una sfera di magia oscura. Al contatto con l\'unità nemica, la sfera infligge danni magici e inchioda a terra l\'unità per un periodo di tempo.', 'Morgana', 64, 0),
('Luce perforante', 'Q', 'Lucian spara un raggio di luce perforante attraverso un bersaglio.', 'Lucian', 0, 65),
('Maledizione della mummia triste', 'R', 'Amumu avvolge i nemici nelle vicinanze con le sue bende, applicando la sua maledizione, danneggiandoli e impedendo loro di attaccare o muoversi.', 'Amumu', 95, 0),
('Malìa amorosa', 'E', 'Ahri manda un bacio che danneggia e ammalia un nemico, facendolo camminare inerme verso di lei e facendogli subire più danni dalle sue abilità.', 'Ahri', 75, 0),
('Marchio dell\'assassino', 'Q', 'Akali scaglia i suoi kama contro un bersaglio, infliggendo danni magici e marcandolo per 6 secondi. Gli attacchi di Akali contro un bersaglio marcato attivano e consumano la marcatura, causando danni aggiuntivi e ripristinando energia.', 'Akali', 75, 0),
('Marchio della morte', 'R', 'Zed si lascia un\'ombra alle spalle e scatta verso il campione bersaglio, marchiandolo per la morte. Dopo 3 secondi il marchio si attiva, infliggendo una percentuale dei danni inflitti da Zed durante la presenza del marchio. Se il campione muore con Marchio della morte, Zed può ottenere una porzione del suo attacco fisico.', 'Zed', 0, 140),
('Maree di sangue', 'E', 'Vladimir utilizza la sua salute per caricare una riserva di sangue che, una volta rilasciata, infligge danni nell\'area che lo circonda, ma che può essere anche bloccata dalle unità nemiche.', 'Vladimir', 70, 0),
('Mareggiata', 'R', 'Evoca un\'immensa mareggiata che sbalza in aria i nemici, li rallenta e li danneggia. Gli alleati colpiti ottengono il doppio dell\'effetto di Maree dirompenti.', 'Nami', 95, 0),
('Massacro', 'R', 'Aatrox attinge al sangue dei nemici, danneggiando i campioni nemici vicini a lui e ottenendo velocità d\'attacco e gittata extra per una breve durata.', 'Aatrox', 20, 90),
('Meditazione', 'W', 'Master Yi rinvigorisce con il potere della concentrazione, recuperando salute e subendo meno danni per un breve periodo di tempo. Inoltre ottiene cariche di Doppio colpo e mette in pausa la durata di Stile Wuju e Agilità superiore per ogni secondo di canalizzazione.', 'Master Yi', 0, 40),
('Monsone', 'R', 'Janna si circonda di una tempesta magica, che respinge i nemici. Dopo che la tempesta si è calmata, un vento rassicurante cura gli alleati nelle vicinanze finché l\'abilità è attiva.', 'Janna', 89, 0),
('Morsi del freddo', 'Q', 'Braum lancia del ghiaccio con lo scudo, rallentando e infliggendo danni magici.', 'Braum', 20, 50),
('Morso glaciale', 'E', 'Con un battito d\'ali Anivia scaglia una folata gelida verso il bersaglio, infliggendo una piccola quantità di danni. Se il bersaglio è stato prima rallentato da Sfera glaciale o danneggiato da una Tempesta glaciale completamente formata, i danni sono raddoppiati.', 'Anivia', 25, 0),
('Morte turbinante', 'R', 'Draven scaglia due enormi asce per infliggere danni fisici ai nemici. Morte turbinante inverte lentamente il senso di marcia, tornando da Draven dopo aver colpito un campione nemico. Draven può attivare questa abilità mentre le asce volano, per farle tornare prima. Infligge meno danni a ogni unità colpita e si azzera quando le asce cambiano direzione.', 'Draven', 0, 134),
('Muro di vento', 'W', 'Crea un muro mobile che blocca i proiettili nemici.', 'Yasuo', 0, 0),
('Occhio del ciclone', 'E', 'Janna evoca una tempesta difensiva che protegge un campione o una torre alleata dai danni, aumentando il suo attacco fisico.', 'Janna', 30, 0),
('Ode alla celerità', 'E', 'Sona suona l\'Ode alla celerità, conferendo velocità di movimento bonus agli alleati nelle vicinanze. Sona ottiene un\'aura temporanea, che conferisce ai campioni alleati, vicini e toccati dalla zona velocità di movimento, bonus al loro prossimo attacco.', 'Sona', 69, 0),
('Ombra vivente', 'W', 'L\'ombra di Zed scatta in avanti, rimanendo in posizione per 5 secondi e imitando le sue abilità. Zed può riattivare l\'abilità per fare cambio di posto con l\'ombra.\r\n\r\n', 'Zed', 0, 0),
('Ora finale', 'R', 'Preparandosi per un confronto epico, Vayne guadagna attacco fisico bonus, Invisibilità quando fa la Capriola e triplica la velocità di movimento bonus da Cacciatrice notturna.', 'Vayne', 0, 140),
('Pacificatore di Piltover', 'Q', 'Caitlyn carica il suo fucile per 1 secondo per sparare un colpo penetrante che infligge danni fisici. Dopo aver colpito il primo bersaglio il colpo diventa piu ampio ma infligge meno danni.', 'Caitlyn', 0, 95),
('Passaggio oscuro', 'W', 'Thresh lancia una lanterna che protegge i campioni alleati vicini dai danni. Gli alleati possono cliccare sulla lanterna per scattare da Thresh.', 'Thresh', 45, 0),
('Pegno di sangue', 'W', 'Quando è attivata, Aatrox infligge danni bonus e riempie una porzione del suo Pozzo di sangue a ogni terzo attacco. Quando è disattivata Aatrox recupera salute ogni terzo attacco.', 'Aatrox', 0, 75),
('Perforazione', 'Q', 'Lancia una rapida lancia che passa oltre i nemici che uccide.', 'Kalista', 0, 86),
('Pilastro di fiamme', 'W', 'Dopo un breve ritardo, Brand crea un Pilastro di fiamme nell\'area bersaglio, infliggendo danni magici alle unità nemiche nella zona. Le unità in fiamme subiscono il 25% di danni in più.', 'Brand', 70, 0),
('Pioggia di frecce', 'E', 'Varus spara una pioggia di frecce che infliggono danni fisici e profanano il terreno. Il suolo profanato rallenta la velocità di movimento dei nemici e riduce la rigenerazione e la guarigione su se stessi.', 'Varus', 30, 30),
('Piuma incantata', 'Q', 'Scaglia una piuma magica che infligge danni magici. Colpire un campione o un mostro epico permette a Rakan di curare i suoi alleati.', 'Rakan', 68, 0),
('Piumaggio letale', 'W', 'Xayah crea una tempesta di lame che aumenta la sua velocità d\'attacco base e i danni, oltre a conferirle del movimento se attacca un campione.', 'Xayah', 0, 70),
('Polverizzare', 'Q', 'Alistar colpisce il suolo, infliggendo danni ai nemici nelle vicinanze e lanciandoli in aria.', 'Alistar', 30, 10),
('Presa razzo', 'Q', 'Blitzcrank spara la sua mano destra alla ricerca di un avversario da afferrare, infliggendogli danni e portandolo a sé.', 'Blitzcrank', 55, 0),
('Prigione acquatica', 'Q', 'Invia una bolla verso un\'area bersaglio, infliggendo danni e stordendo i nemici all\'impatto.', 'Nami', 73, 0),
('Protocollo di precisione', 'Q', 'Il prossimo attacco di Camille infligge danni bonus e conferisce velocità di movimento bonus. Questo incantesimo può essere rilanciato per un breve periodo di tempo. Infligge molti più danni se Camille fa passare del tempo tra i due attacchi.', 'Camille', 0, 79),
('Pugno della giustizia', 'E', 'Galio fa un passo indietro e carica, lanciando in aria il primo campione nemico che incontra.', 'Galio', 56, 0),
('Pulsar della forza', 'E', 'Kassadin attinge all\'energia degli incantesimi lanciati nelle vicinanze. Una volta carico, Kassadin può usare Pulsar della forza e rallentare i nemici in un\'area conica davanti a sé.', 'Kassadin', 76, 0),
('Raffica di frecce', 'W', 'Ashe lancia 9 frecce che infliggono maggiori danni in un\'area conica dinnanzi a lei. Applica anche Colpo di ghiaccio.', 'Ashe', 0, 85),
('Ragnarok', 'R', 'Olaf diventa momentaneamente immune agli impedimenti.', 'Olaf', 0, 95),
('Rampino', 'E', 'Camille si porta verso un muro, balzando e respingendo i nemici quando atterra.', 'Camille', 0, 20),
('Rete calibro 90', 'E', 'Caitlyn spara una pesante rete per rallentare il bersaglio. Il rinculo la spinge all\'indietro.', 'Caitlyn', 20, 10),
('Riposo dell\'Agnella', 'R', 'L\'Agnella conferisce a tutti gli esseri viventi all\'interno di una zona una tregua con la morte. Fino alla fine dell\'effetto, nulla può morire. Alla fine, tutte le unità vengono curate.', 'Kindred', 10, 95),
('Ruggito di battaglia', 'W', 'Rengar lancia un ruggito di battaglia, infliggendo danni ai nemici e guarendo parte degli ultimi danni subiti.', 'Rengar', 20, 20),
('Sabbie mobili', 'E', 'Azir si ripara brevemente e scatta verso uno dei suoi Soldati della sabbia, danneggiando i nemici. Se colpisce un campione nemico, prepara immediatamente un nuovo soldato da schierare e ferma il suo scatto.', 'Azir', 55, 0),
('Salto fasico', 'E', 'Ekko esegue una manovra evasiva mentre carica il suo Motore-Z. Il suo prossimo attacco infligge danni bonus e distorce la realtà, teletrasportandolo verso il suo bersaglio.', 'Ekko', 57, 0),
('Sangue bollente', 'W', 'Nunu scalda il proprio sangue e quello di un alleato, aumentando la velocità di attacco, di movimento e il potere magico.', 'Nunu', 34, 30),
('Sbarramento energetico', 'R', 'Ezreal incanala energia per 1 secondo per sparare un potente colpo che infligge ingenti danni alle unità che attraversa (infligge il 10% di danni in meno per ogni unità che attraversa).', 'Ezreal', 0, 100),
('Scatto sanguigno', 'W', 'Draven ottiene un aumento di velocità di movimento e attacco. Il bonus alla velocità di movimento diminuisce rapidamente per tutta la durata dell\'effetto. Prendere un\'ascia rotante azzera il tempo di ricarica di Scatto sanguigno.', 'Draven', 0, 10),
('Scorta imperiale', 'R', 'Azir evoca un muro di soldati che carica in avanti, respingendo e danneggiando i nemici.', 'Azir', 130, 0),
('Scudo dell\'alba', 'Q', 'Leona usa il suo scudo per compiere il prossimo attacco base, infliggendo danni magici bonus e stordendo il bersaglio.', 'Leona', 76, 0),
('Scudo di Durand', 'W', 'Galio carica una posizione difensiva, muovendosi lentamente. Al rilascio, provoca e danneggia i nemici nelle vicinanze.', 'Galio', 78, 0),
('Scudo nero', 'E', 'Piazza una barriera protettiva intorno a un campione alleato, assorbendo i danni magici ed eventuali impedimenti finché lo scudo non viene penetrato o la protezione si esaurisce.', 'Morgana', 34, 0),
('Scudo pirico', 'E', 'Conferisce ad Annie e Tibbers percentuali aumentati di resistenza ai danni e danneggia i nemici che attaccano con attacchi base.', 'Annie', 15, 0),
('Sentinella', 'W', 'Attiva per inviare un\'anima a pattugliare, rivelando l\'area davanti al suo campo visivo.', 'Kalista', 0, 0),
('Sfera del nulla', 'Q', 'Kassadin spara una sfera di energia del Vuoto ad un bersaglio, infliggendogli danni ed interrompendo le canalizzazioni. L\'energia in eccesso gli si plasma addosso, conferendo uno scudo temporaneo che assorbe i danni magici.', 'Kassadin', 83, 0),
('Sfera glaciale', 'Q', 'Anivia unisce le sue ali ed evoca una sfera di ghiaccio che vola verso gli avversari, gelando e danneggiando tutto ciò che incontra. Quando la sfera esplode, infligge moderati danni ad area, stordendo le vittime coinvolte.', 'Anivia', 75, 0),
('Sferzata', 'E', 'Gli attacchi di Thresh diventano più forti, infliggendo più danni quanto più attende tra un attacco e l\'altro. All\'attivazione, Thresh esegue una spazzata con la sua catena, respingendo i nemici colpiti nella direzione del colpo.', 'Thresh', 35, 0),
('Sfida mirabolante', 'R', 'Fiora rivela i quattro punti vitali di un campione nemico e ottiene velocità di movimento quando gli è vicina. Se Fiora colpisce tutti e 4 i Punti vitali o se il bersaglio muore dopo che ne ha colpito almeno uno, Fiora e i suoi alleati nell\'area vengono curati per pochi secondi.', 'Fiora', 0, 160),
('Shuriken rasoio', 'Q', 'Zed e la sua ombra lanciano le loro lame rotanti, infliggendo danni a tutti i bersagli che trapassano.', 'Zed', 0, 65),
('Soffio galattico', 'R', 'Aurelion Sol proietta un getto di puro fuoco stellare che infligge danni e rallenta tutti i nemici colpiti e respinge i nemici nelle vicinanze a distanza di sicurezza.', 'Aurelion Sol', 115, 0),
('Sorgi!', 'W', 'Azir evoca un Soldato della sabbia che attacca i bersagli nelle vicinanze, sostituendo gli attacchi base contro i bersagli entro la portata del Soldato. Gli attacchi infliggono danni magici ai nemici lungo una linea retta. Inoltre, Sorgi! conferisce passivamente velocità d\'attacco ad Azir e ai suoi Soldati delle delle sabbie.', 'Azir', 60, 0),
('Spostamento arcano', 'E', 'Ezreal si teletrasporta vicino a una posizione bersaglio e spara un dardo a ricerca che colpisce il nemico più vicino.', 'Ezreal', 44, 40),
('Stella vagante', 'Q', 'Zoe spara un proiettile che può deviare durante il volo. Infligge più danni in base a quanto vola in linea retta.', 'Zoe', 80, 0),
('Sterminio', 'R', 'Lucian scatena una pioggia di colpi con le sue armi.', 'Lucian', 0, 117),
('Stile Wuju', 'E', 'Master Yi diventa abile nell\'arte del Wuju, aumentando passivamente la potenza dei suoi attacchi fisici. Attivare lo Stile Wuju conferisce danni puri bonus agli attacchi base, ma poi il bonus passivo svanisce durante la ricarica.', 'Master Yi', 0, 0),
('Suolo del tormento', 'W', 'Infetta un\'area con uno speciale suolo sconsacrato, che fa sì che le unità nemiche che stanno sulla zona colpita subiscano danni continui.', 'Morgana', 97, 0),
('Supernova', 'Q', 'Aurelion Sol crea un disco in espansione che esplode infliggendo danni e stordendo i nemici quando si allontana troppo da lui.', 'Aurelion Sol', 65, 0),
('Superpugno', 'E', 'Blitzcrank carica il suo pugno in modo che il prossimo attacco infligga il doppio dei danni e lanci il bersaglio in aria.', 'Blitzcrank', 45, 0),
('Taglio del cristallo', 'Q', 'Skarner attacca con i suoi artigli, infliggendo danni fisici a tutti i nemici nelle vicinanze e caricandosi con energia del cristallo per alcuni secondi se colpisce un\'unità. Se lancia nuovamente Taglio del cristallo quando è carico di Energia del cristallo, infligge danni magici.', 'Skarner', 0, 60),
('Taglio della crescente', 'E', 'Akali si esibisce in un florilegio di kama, infliggendo danni in base al suo attacco fisico bonus e al suo potere magico. Quando Taglio della crescente uccide un\'unità, ha un tempo di ricarica minore.', 'Akali', 40, 35),
('Tempesta d\'acciaio', 'Q', 'Un colpo mirato base. Dopo due Tempeste d\'acciaio consecutive, la prossima sarà un tornado che lancia in aria i nemici.', 'Yasuo', 0, 70),
('Tempesta glaciale', 'R', 'Anivia evoca una pioggia di ghiaccio e grandine, danneggiando i nemici e rallentandone l\'avanzata.', 'Anivia', 110, 0),
('Tempesta ululante', 'Q', 'Creando un cambiamento nella pressione e nella temperatura, Janna è in grado di creare un piccolo tornado che cresce col tempo. Può attivare di nuovo l\'incantesimo per rilasciare il tornado. Al rilascio, il tornado vola verso la direzione in cui è stato lanciato, infliggendo danni e lanciando in aria i nemici sulla sua strada.', 'Janna', 67, 0),
('Timore incombente', 'E', 'L\'Agnella spara un colpo ben piazzato, rallentando il bersaglio. Se l\'Agnella attacca il bersaglio altre due volte, il terzo attacco fa balzare il Lupo addosso al bersaglio, straziandolo con una grande quantità di danni.', 'Kindred', 0, 23),
('Toccata e fuga', 'R', 'Ottiene velocità di movimento, ammalia e infligge danni magici ai nemici toccati.', 'Rakan', 100, 0),
('Trappola per Yordle', 'W', 'Caitlyn piazza una trappola per stanare gli yordle. Se attivata, la trappola rivela e immobilizza il campione nemico per 1,5 secondi.', 'Caitlyn', 10, 0),
('Trasfusione', 'Q', 'Vladimir ruba vita dal nemico bersaglio. Quando la riserva di Vladimir è piena, danni e cure di Trasfusione aumenteranno di molto per un breve periodo.', 'Vladimir', 75, 0),
('Travolgere', 'E', 'Alistar travolge le unità nemiche vicine, ignorando le collisioni con le unità e ottenendo una carica se danneggia un campione nemico. Al massimo delle cariche, l\'attacco base successivo di Alistar contro un campione nemico infligge danni magici aggiuntivi e stordisce.', 'Alistar', 40, 0),
('Tuffo nel portale', 'R', 'Ti teletrasporti in una posizione vicina per un secondo. Poi ti riteletrasporti indietro.', 'Zoe', 95, 0),
('Tumulto delle sabbie', 'Q', 'Azir invia i Soldati della sabbia in un punto. I Soldati della sabbia infliggono danni magici ai nemici che attraversano e applicano un rallentamento per 1 secondo.', 'Azir', 75, 0),
('Tumulto di piume', 'R', 'Xayah salta e diventa non bersagliabile, per poi lanciare una raffica di daghe le quali lasciano piume che può richiamare.', 'Xayah', 0, 123),
('Ultimatum hextech', 'R', 'Camille scatta verso un campione bersaglio, ancorandolo all\'area. Infligge anche danni magici bonus al bersaglio con gli attacchi base.', 'Camille', 0, 98),
('Ultimo respiro', 'R', 'Si muove verso un\'unità e la colpisce ripetutamente, infliggendo danni ingenti. Può essere lanciato solo su bersagli in aria.', 'Yasuo', 0, 145),
('Velo di penombra', 'W', 'Akali si teletrasporta in una posizione vicina, lasciando una copertura di fumo nella sua posizione precedente. Dentro il Velo, Akali ottiene Invisibilità e guadagna velocità di movimento. Attaccare o usare abilità svela brevemente la sua presenza. I nemici all\'interno del fumo hanno la velocità di movimento ridotta.', 'Akali', 20, 0),
('Venti di guerra', 'Q', 'Galio spara due raffiche di vento che convergono in un grande tornado.', 'Galio', 83, 0),
('Viaggio magico', 'E', 'Bard apre un portale nel terreno vicino. Gli alleati e i nemici possono attraversarlo in un viaggio a senso unico oltre il terreno.', 'Bard', 90, 0),
('Volo oscuro', 'Q', 'Aatrox salta e colpisce una posizione bersaglio, infliggendo danni e lanciando in aria le unità vicine all\'impatto.', 'Aatrox', 0, 80),
('Volontà indistruttibile', 'R', 'Alistar si abbandona a un feroce ruggito, liberandosi di eventuali effetti di controllo e riducendo i danni fisici e magici in ingresso per tutta la durata dell\'incantesimo.', 'Alistar', 0, 90),
('Volpe di fuoco', 'W', 'Ahri libera tre volpi di fuoco che localizzano e attaccano i nemici nelle vicinanze.', 'Ahri', 45, 0),
('Zefiro', 'W', 'Janna evoca un elementale dell\'aria che aumenta passivamente la sua velocità di movimento e le permette di passare attraverso le unità. Può anche attivare l\'abilità per infliggere danni e rallentare la velocità di movimento del nemico. L\'effetto passivo svanisce quando l\'abilità è in ricarica.', 'Janna', 43, 0),
('Zero Assoluto', 'R', 'Nunu assorbe il calore dell\'area, rallentando i nemici nelle vicinanze. Al termine di Zero Assoluto, infligge danni ingenti a tutti i nemici nell\'area.', 'Nunu', 134, 0);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `numero_aspetti`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `numero_aspetti` (
`Numero_aspetti` bigint(21)
);

-- --------------------------------------------------------

--
-- Struttura della tabella `oggetto`
--

CREATE TABLE `oggetto` (
  `Nome` varchar(50) NOT NULL,
  `Tipologia` varchar(40) DEFAULT NULL,
  `Costo` int(11) DEFAULT NULL,
  `Statistiche_aggiungive` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `oggetto`
--

INSERT INTO `oggetto` (`Nome`, `Tipologia`, `Costo`, `Statistiche_aggiungive`) VALUES
('Calzari del ninja', 'Movimento', 1100, 35),
('Calzari di mercurio', 'Movimento', 1200, 30),
('Copricapo di Wooglet', 'Magia', 3500, 150),
('Corazza dell\'uomo morto', 'Difesa', 2900, 120),
('Dente di Nashor', 'Magia', 3000, 50),
('Elmo adattivo', 'Difesa', 2800, 50),
('Frammento d\'infinito', 'Attacco', 3400, 70),
('Fulcro dei geli', 'Difesa', 2700, 100),
('Gambali del berserker', 'Movimento', 1500, 40),
('Idra famelica', 'Attacco', 3500, 75),
('La Bramasangue', 'Attacco', 3700, 80),
('Lama sanguigna', 'Attacco', 2400, 45),
('Lastrapietra del gargoyle', 'Difesa', 2500, 40),
('Legamagia', 'Magia', 2800, 95),
('Mantello del Sole', 'Difesa', 2900, 80),
('Maschera dell\'abisso', 'Difesa', 2900, 65),
('Medaglione dei Solari di ferro', 'Difesa', 2700, 85),
('Orgoglio di Randuin', 'Difesa', 2900, 100),
('Scettro di cristallo di Rylai', 'Magia', 2600, 80),
('Stivali della rapidità', 'Movimento', 900, 20),
('Velo della Banshee', 'Difesa', 3000, 70);

-- --------------------------------------------------------

--
-- Struttura della tabella `partita`
--

CREATE TABLE `partita` (
  `Evocatore` varchar(20) NOT NULL,
  `Cronologia` datetime NOT NULL,
  `Esito` varchar(20) DEFAULT NULL,
  `Campione_usato` varchar(20) NOT NULL,
  `Voto` char(1) NOT NULL,
  `Aspetto_usato` varchar(90) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `partita`
--

INSERT INTO `partita` (`Evocatore`, `Cronologia`, `Esito`, `Campione_usato`, `Voto`, `Aspetto_usato`) VALUES
('Ayrok', '2018-04-01 13:32:00', 'Sconfitta', 'Ashe', 'C', NULL),
('Ayrok', '2018-04-18 15:14:31', 'Vittoria', 'Ashe', 'S', NULL),
('Ayrok', '2018-04-19 11:09:24', 'Sconfitta', 'Ahri', 'C', NULL),
('Ayrok', '2018-04-20 22:43:43', 'Sconfitta', 'Ahri', 'C', NULL),
('CanonStylus', '2018-03-19 13:14:41', 'Vittoria', 'Thresh', 'A', 'Thresh Stella Oscura'),
('CanonStylus', '2018-04-03 10:23:12', 'Vittoria', 'Ezreal', 'A', 'Ezreal Pulsefire'),
('CanonStylus', '2018-05-30 17:16:08', 'Vittoria', 'Ezreal', 'S', 'Ezreal Pulsefire'),
('CanonStylus', '2018-05-31 15:11:43', 'Sconfitta', 'Skarner', 'C', 'Skarner Terra Runica'),
('CrazyBirraiol', '2018-03-16 17:46:16', 'Vittoria', 'Anivia', 'S', 'Anivia Preistorica'),
('CrazyBirraiol', '2018-04-29 21:29:30', 'Vittoria', 'Vladimir', 'S', NULL),
('CrazyBirraiol', '2018-04-30 15:41:11', 'Sconfitta', 'Anivia', 'C', 'Anivia Nerogelo'),
('CrazyBirraiol', '2018-05-01 13:19:29', 'Sconfitta', 'Nunu', 'B', NULL),
('DarkVo0doo', '2018-04-01 22:41:24', 'Sconfitta', 'Vayne', 'C', 'PROGETTO:Vayne'),
('DarkVo0doo', '2018-04-02 08:50:00', 'Vittoria', 'Graves', 'S', 'Graves Mercenario'),
('DarkVo0doo', '2018-04-13 15:37:41', 'Vittoria', 'Vayne', 'A', 'PROGETTO:Vayne'),
('DarkVo0doo', '2018-04-16 10:24:19', 'Sconfitta', 'Jhin', 'A', 'Jhin Mezzogiorno di Fuoco'),
('Deumion', '2018-02-08 15:20:08', 'Vittoria', 'Alistar', 'A', 'Alistar Infernale'),
('Deumion', '2018-04-22 08:50:14', 'Vittoria', 'Ekko', 'A', NULL),
('Deumion', '2018-04-23 15:19:01', 'Sconfitta', 'Brand', 'C', 'Brand Crio-nucleo'),
('Deumion', '2018-04-24 17:12:24', 'Vittoria', 'Alistar', 'S', 'Alistar Infernale'),
('dracos777', '2018-03-22 17:47:12', 'Sconfitta', 'Brand', 'S', 'Brand Apocalittico'),
('dracos777', '2018-05-06 13:37:09', 'Vittoria', 'Alistar', 'S', NULL),
('dracos777', '2018-05-07 09:22:10', 'Sconfitta', 'Akali', 'C', 'Akali Cacciatrice di Teste'),
('dracos777', '2018-05-08 17:25:22', 'Vittoria', 'Blitzcrank', 'S', 'iBlitzcrank'),
('Felix889', '2018-05-01 13:48:09', 'Vittoria', 'Aurelion Sol', 'S', NULL),
('Felix889', '2018-05-02 22:36:17', 'Vittoria', 'Lucian', 'A', NULL),
('Felix889', '2018-05-03 23:37:18', 'Sconfitta', 'Zed', 'S', NULL),
('Felix889', '2018-05-04 17:27:32', 'Vittoria', 'Zed', 'S', NULL),
('Hiken96', '2018-04-12 16:59:35', 'Vittoria', 'Yasuo', 'S', 'Yasuo Luna di Sangue'),
('Hiken96', '2018-04-14 11:35:12', 'Sconfitta', 'Azir', 'C', 'Azir Signore delle tombe'),
('Hiken96', '2018-05-05 12:50:16', 'Vittoria', 'Galio', 'S', NULL),
('Hiken96', '2018-05-12 10:26:27', 'Vittoria', 'Yasuo', 'A', 'Yasuo Luna di Sangue'),
('howIrain', '2018-04-12 16:46:30', 'Sconfitta', 'Janna', 'C', 'Janna Meteorina'),
('howIrain', '2018-04-13 11:23:15', 'VIttoria', 'Janna', 'S', 'Janna Meteorina'),
('howIrain', '2018-05-01 12:29:00', 'Vittoria', 'Thresh', 'A', NULL),
('howIrain', '2018-05-02 11:10:19', 'Sconfitta', 'Janna', 'B', 'Janna Meteorina'),
('LaMaggica', '2018-04-05 13:24:18', 'Sconfitta', 'Ekko', 'B', NULL),
('LaMaggica', '2018-04-05 16:33:24', 'Sconfitta', 'Ekko', 'C', NULL),
('LaMaggica', '2018-04-20 13:22:36', 'Vittoria', 'Master Yi', 'S', 'Master Yi Cacciatore di Teste'),
('LaMaggica', '2018-04-30 13:00:20', 'Sconfitta', 'Draven', 'C', NULL),
('Mario889', '2018-04-03 13:51:18', 'Sconfitta', 'Fiora', 'C', 'PROGETTO: Fiora'),
('Mario889', '2018-04-11 11:18:18', 'Vittoria', 'Kassadin', 'A', NULL),
('Mario889', '2018-05-30 21:29:00', 'Sconfitta', 'Fiora', 'C', 'PROGETTO: Fiora'),
('Mario889', '2018-05-31 11:18:13', 'Vittoria', 'Olaf', 'A', NULL),
('Master Shuppets', '2018-02-09 13:25:34', 'Sconfitta', 'Rakan', 'B', 'Rakan Alba Cosmica'),
('Master Shuppets', '2018-04-26 15:29:42', 'Vittoria', 'Leona', 'S', 'PROGETTO:Leona'),
('Master Shuppets', '2018-04-30 17:30:00', 'Sconfitta', 'Annie', 'C', NULL),
('Master Shuppets', '2018-05-01 09:30:11', 'Vittoria', 'Rakan', 'S', 'Rakan Alba Cosmica'),
('MirrorUp', '2018-03-07 15:23:21', 'Vittoria', 'Zed', 'B', 'Zed Elettrolama'),
('MirrorUp', '2018-04-28 15:32:29', 'Sconfitta', 'Alistar', 'C', NULL),
('MirrorUp', '2018-04-30 10:14:21', 'Vittoria', 'Zed', 'S', 'Zed Elettrolama'),
('MirrorUp', '2018-05-04 22:35:16', 'Sconfitta', 'Amumu', 'B', NULL),
('Oh My Darph', '2018-05-13 14:23:08', 'Vittoria', 'Caitlyn', 'A', 'Caitlyn Cacciatrice di Teste'),
('Oh My Darph', '2018-05-14 11:21:15', 'Sconfitta', 'Bard', 'C', NULL),
('Oh My Darph', '2018-05-15 21:47:04', 'Sconfitta', 'Bard', 'C', NULL),
('Oh My Darph', '2018-05-16 16:23:32', 'Vittoria', 'Xayah', 'S', NULL),
('xTigerMaster', '2018-02-15 20:14:15', 'Sconfitta', 'Akali', 'C', NULL),
('xTigerMaster', '2018-03-15 20:48:18', 'Vittoria', 'Camille', 'A', 'Programma Camille'),
('xTigerMaster', '2018-03-20 21:27:07', 'Sconfitta', 'Aatrox', 'B', 'Aatrox Giustiziere'),
('xTigerMaster', '2018-04-18 09:48:25', 'Vittoria', 'Jhin', 'S', 'Jhin Luna di Sangue'),
('xXDarkXx', '2018-04-25 13:31:19', 'Sconfitta', 'Aatrox', 'C', NULL),
('xXDarkXx', '2018-04-26 10:46:07', 'Sconfitta', 'Aatrox', 'C', NULL),
('xXDarkXx', '2018-04-27 16:34:18', 'Vittoria', 'Ezreal', 'A', NULL),
('xXDarkXx', '2018-04-28 20:33:18', 'Sconfitta', 'Nunu', 'C', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `runa`
--

CREATE TABLE `runa` (
  `Nome` varchar(40) NOT NULL,
  `Incremento_Attacco_Fisico` int(11) NOT NULL,
  `Incremento_Difesa` int(11) NOT NULL,
  `Incremento_Potere_Magico` int(11) NOT NULL,
  `Incremento_Movimento` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `runa`
--

INSERT INTO `runa` (`Nome`, `Incremento_Attacco_Fisico`, `Incremento_Difesa`, `Incremento_Potere_Magico`, `Incremento_Movimento`) VALUES
('Benedizione del cantore', 0, 30, 35, 20),
('Condottiero', 30, 0, 30, 10),
('Forza delle ere', 15, 15, 10, 10),
('Frenesia', 45, 10, 0, 15),
('Legame di pietra', 0, 40, 10, 15),
('Presa dell\'immortale', 15, 10, 15, 5),
('Scatto del razziatore', 0, 15, 35, 30),
('Sentenza del tuono', 50, 5, 15, 10),
('Tocco della morte', 0, 5, 45, 10);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `somma_essenze_spese_in_campioni`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `somma_essenze_spese_in_campioni` (
`Possessore` varchar(40)
,`Somma_essenze_spese` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Struttura della tabella `statistiche_campione`
--

CREATE TABLE `statistiche_campione` (
  `Nome_campione` varchar(20) NOT NULL,
  `Movimento` int(11) NOT NULL,
  `Difesa` int(11) NOT NULL,
  `Attacco_Fisico` int(11) NOT NULL,
  `Potere_Magico` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dump dei dati per la tabella `statistiche_campione`
--

INSERT INTO `statistiche_campione` (`Nome_campione`, `Movimento`, `Difesa`, `Attacco_Fisico`, `Potere_Magico`) VALUES
('Aatrox', 345, 33, 70, 14),
('Ahri', 330, 20, 12, 60),
('Akali', 350, 31, 45, 58),
('Alistar', 330, 44, 60, 24),
('Amumu', 335, 33, 30, 53),
('Anivia', 325, 21, 9, 51),
('Annie', 335, 19, 5, 55),
('Ashe', 325, 20, 65, 0),
('Aurelion Sol', 325, 15, 0, 57),
('Azir', 335, 19, 5, 52),
('Bard', 330, 34, 9, 55),
('Blitzcrank', 325, 45, 20, 35),
('Brand', 340, 21, 6, 55),
('Braum', 335, 47, 40, 45),
('Caitlyn', 325, 32, 65, 0),
('Camille', 340, 35, 68, 20),
('Draven', 330, 35, 70, 0),
('Ekko', 340, 32, 10, 55),
('Ezreal', 325, 31, 65, 0),
('Fiora', 345, 33, 65, 0),
('Galio', 335, 40, 30, 45),
('Graves', 340, 33, 69, 0),
('Irelia', 340, 35, 60, 0),
('Janna', 315, 28, 10, 45),
('Jhin', 330, 29, 61, 0),
('Kalista', 325, 28, 66, 0),
('Kassadin', 340, 23, 10, 58),
('Kindred', 325, 29, 65, 0),
('Leona', 335, 47, 10, 23),
('Lucian', 335, 33, 65, 0),
('Master Yi', 355, 33, 68, 15),
('Morgana', 335, 25, 10, 55),
('Nami', 335, 29, 15, 40),
('Nunu', 345, 28, 30, 45),
('Olaf', 350, 45, 60, 0),
('Pantheon', 355, 37, 64, 10),
('Rakan', 335, 36, 30, 55),
('Rengar', 345, 34, 65, 0),
('Skarner', 335, 45, 40, 30),
('Sona', 325, 28, 0, 45),
('Thresh', 335, 40, 30, 30),
('Varus', 330, 32, 70, 5),
('Vayne', 330, 28, 68, 3),
('Vladimir', 335, 24, 0, 50),
('Xayah', 330, 23, 69, 0),
('Yasuo', 345, 30, 60, 0),
('Zed', 345, 32, 63, 5),
('Zoe', 340, 20, 0, 58);

-- --------------------------------------------------------

--
-- Struttura per vista `campioni_più_acquistati_in_corsia_centrale`
--
DROP TABLE IF EXISTS `campioni_più_acquistati_in_corsia_centrale`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `campioni_più_acquistati_in_corsia_centrale`  AS  select `c`.`Nome` AS `Nome`,count(`cp`.`Possessore`) AS `Possessori` from (`campione_posseduto` `cp` join `campione` `c` on((`c`.`Nome` = `cp`.`Nome_Campione`))) where `c`.`Nome` in (select `info`.`Campione` from `informazioni_campione` `info` where (`info`.`Corsia_principale` = 'Centrale')) group by `c`.`Nome` order by count(`cp`.`Possessore`) desc limit 5 ;

-- --------------------------------------------------------

--
-- Struttura per vista `classifica_spese_aspetti`
--
DROP TABLE IF EXISTS `classifica_spese_aspetti`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `classifica_spese_aspetti`  AS  select `a`.`Proprietario` AS `Proprietario`,sum(`b`.`Costo_in_Denaro`) AS `Denaro_speso` from (`aspetto_posseduto` `a` join `aspetto` `b` on((`a`.`Nome` = `b`.`Nome`))) where (`a`.`Modalità_Acquisto` = 'Denaro') group by `a`.`Proprietario` order by sum(`b`.`Costo_in_Denaro`) desc limit 3 ;

-- --------------------------------------------------------

--
-- Struttura per vista `media_costo_oggetti`
--
DROP TABLE IF EXISTS `media_costo_oggetti`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `media_costo_oggetti`  AS  select `e`.`Giocatore` AS `Giocatore`,avg(`o`.`Costo`) AS `Media_costo_oggetti` from ((`equipaggiamento` `e` join `oggetto` `o` on(((`o`.`Nome` = `e`.`Oggetto_uno`) or (`o`.`Nome` = `e`.`Oggetto_due`) or (`o`.`Nome` = `e`.`Oggetto_tre`) or (`o`.`Nome` = `e`.`Oggetto_quattro`)))) join `partita` `p` on(((`e`.`Cronologia` = `p`.`Cronologia`) and (`e`.`Giocatore` = `p`.`Evocatore`)))) where (`e`.`Giocatore` in (select `g`.`Nome` from `giocatore` `g` where (`g`.`Livello_Onore` > 4)) and (`p`.`Esito` = 'Vittoria')) group by `e`.`Giocatore` ;

-- --------------------------------------------------------

--
-- Struttura per vista `media_maestrie_lega_1`
--
DROP TABLE IF EXISTS `media_maestrie_lega_1`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `media_maestrie_lega_1`  AS  select `cp`.`Possessore` AS `Possessore`,avg(`cp`.`Maestria`) AS `Media_Maestria` from `campione_posseduto` `cp` where ((`cp`.`Maestria` >= 4) and `cp`.`Possessore` in (select `cla`.`Utente` from `classifiche` `cla` where (`cla`.`ID_Lega_SoloDuo` = 1)) and `cp`.`Possessore` in (select `club`.`Capo` from `club` where (`club`.`Data_Creazione` > '2015-01-01'))) group by `cp`.`Possessore` having (`Media_Maestria` > 6) ;

-- --------------------------------------------------------

--
-- Struttura per vista `numero_aspetti`
--
DROP TABLE IF EXISTS `numero_aspetti`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `numero_aspetti`  AS  select count(`p`.`Aspetto_usato`) AS `Numero_aspetti` from `partita` `p` where ((`p`.`Aspetto_usato` is not null) and `p`.`Aspetto_usato` in (select `asp`.`Nome` from `aspetto` `asp` where ((`asp`.`Tipologia` = 'Epica') or (`asp`.`Tipologia` = 'Classica'))) and `p`.`Campione_usato` in (select `info`.`Campione` from `informazioni_campione` `info` where (`info`.`Corsia_secondaria` is not null)) and (`p`.`Esito` = 'Sconfitta')) ;

-- --------------------------------------------------------

--
-- Struttura per vista `somma_essenze_spese_in_campioni`
--
DROP TABLE IF EXISTS `somma_essenze_spese_in_campioni`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `somma_essenze_spese_in_campioni`  AS  select `cp`.`Possessore` AS `Possessore`,sum(`c`.`Costo_in_Essenze`) AS `Somma_essenze_spese` from (`campione_posseduto` `cp` join `campione` `c` on((`cp`.`Nome_Campione` = `c`.`Nome`))) where ((`cp`.`Modalità_Acquisto` = 'Essenze') and `cp`.`Possessore` in (select `giocatore`.`Nome` from `giocatore` where ((`giocatore`.`Livello` > 30) and (`giocatore`.`Data_Iscrizione` > '2013-01-01') and `giocatore`.`Nome` in (select `classifiche`.`Utente` from `classifiche` where (`classifiche`.`ID_Lega_SoloDuo` = 3))))) group by `cp`.`Possessore` having (`Somma_essenze_spese` < 22000) ;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `aspetto`
--
ALTER TABLE `aspetto`
  ADD PRIMARY KEY (`Nome`),
  ADD KEY `Vincolo1000` (`Campione_Possessore`);

--
-- Indici per le tabelle `aspetto_posseduto`
--
ALTER TABLE `aspetto_posseduto`
  ADD PRIMARY KEY (`Nome`,`Proprietario`),
  ADD KEY `VincoloY` (`Proprietario`);

--
-- Indici per le tabelle `campione`
--
ALTER TABLE `campione`
  ADD PRIMARY KEY (`Nome`);

--
-- Indici per le tabelle `campione_posseduto`
--
ALTER TABLE `campione_posseduto`
  ADD PRIMARY KEY (`Possessore`,`Nome_Campione`),
  ADD KEY `Vincolo78` (`Nome_Campione`);

--
-- Indici per le tabelle `classificata`
--
ALTER TABLE `classificata`
  ADD PRIMARY KEY (`Cronologia`,`Evocatore`),
  ADD KEY `Vincolo999` (`Evocatore`,`Cronologia`);

--
-- Indici per le tabelle `classifiche`
--
ALTER TABLE `classifiche`
  ADD PRIMARY KEY (`Utente`);

--
-- Indici per le tabelle `club`
--
ALTER TABLE `club`
  ADD PRIMARY KEY (`Nome`),
  ADD KEY `Vincolo Nome` (`Capo`);

--
-- Indici per le tabelle `equipaggiamento`
--
ALTER TABLE `equipaggiamento`
  ADD PRIMARY KEY (`Giocatore`,`Cronologia`),
  ADD KEY `Vincolo1` (`Oggetto_uno`),
  ADD KEY `Vincolo2` (`Oggetto_due`),
  ADD KEY `Vincolo3` (`Oggetto_tre`),
  ADD KEY `Vincolo4` (`Oggetto_quattro`),
  ADD KEY `Vincolo7` (`Runa_chiave`),
  ADD KEY `Vincolo5` (`Incantesimo_uno`),
  ADD KEY `Vincolo6` (`Incantesimo_due`);

--
-- Indici per le tabelle `giocatore`
--
ALTER TABLE `giocatore`
  ADD PRIMARY KEY (`Nome`),
  ADD KEY `Vincolo club` (`Club`);

--
-- Indici per le tabelle `incantesimo`
--
ALTER TABLE `incantesimo`
  ADD PRIMARY KEY (`Nome`);

--
-- Indici per le tabelle `informazioni_campione`
--
ALTER TABLE `informazioni_campione`
  ADD PRIMARY KEY (`Campione`);

--
-- Indici per le tabelle `mossa_campione`
--
ALTER TABLE `mossa_campione`
  ADD PRIMARY KEY (`Nome`),
  ADD KEY `Campione` (`Campione`);

--
-- Indici per le tabelle `oggetto`
--
ALTER TABLE `oggetto`
  ADD PRIMARY KEY (`Nome`);

--
-- Indici per le tabelle `partita`
--
ALTER TABLE `partita`
  ADD PRIMARY KEY (`Evocatore`,`Cronologia`),
  ADD KEY `partita_2` (`Campione_usato`),
  ADD KEY `partita_4` (`Aspetto_usato`);

--
-- Indici per le tabelle `runa`
--
ALTER TABLE `runa`
  ADD PRIMARY KEY (`Nome`);

--
-- Indici per le tabelle `statistiche_campione`
--
ALTER TABLE `statistiche_campione`
  ADD PRIMARY KEY (`Nome_campione`);

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `aspetto`
--
ALTER TABLE `aspetto`
  ADD CONSTRAINT `Vincolo1000` FOREIGN KEY (`Campione_Possessore`) REFERENCES `campione` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `aspetto_posseduto`
--
ALTER TABLE `aspetto_posseduto`
  ADD CONSTRAINT `VincoloU` FOREIGN KEY (`Nome`) REFERENCES `aspetto` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `VincoloY` FOREIGN KEY (`Proprietario`) REFERENCES `giocatore` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `campione_posseduto`
--
ALTER TABLE `campione_posseduto`
  ADD CONSTRAINT `Vincolo` FOREIGN KEY (`Possessore`) REFERENCES `giocatore` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo78` FOREIGN KEY (`Nome_Campione`) REFERENCES `campione` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `classificata`
--
ALTER TABLE `classificata`
  ADD CONSTRAINT `Vincolo999` FOREIGN KEY (`Evocatore`,`Cronologia`) REFERENCES `partita` (`Evocatore`, `Cronologia`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `classifiche`
--
ALTER TABLE `classifiche`
  ADD CONSTRAINT `Vincolo222` FOREIGN KEY (`Utente`) REFERENCES `giocatore` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `club`
--
ALTER TABLE `club`
  ADD CONSTRAINT `Vincolo Nome` FOREIGN KEY (`Capo`) REFERENCES `giocatore` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `equipaggiamento`
--
ALTER TABLE `equipaggiamento`
  ADD CONSTRAINT `Vicolo Giocatore-Ora` FOREIGN KEY (`Giocatore`,`Cronologia`) REFERENCES `partita` (`Evocatore`, `Cronologia`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo1` FOREIGN KEY (`Oggetto_uno`) REFERENCES `oggetto` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo2` FOREIGN KEY (`Oggetto_due`) REFERENCES `oggetto` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo3` FOREIGN KEY (`Oggetto_tre`) REFERENCES `oggetto` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo4` FOREIGN KEY (`Oggetto_quattro`) REFERENCES `oggetto` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo5` FOREIGN KEY (`Incantesimo_uno`) REFERENCES `incantesimo` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo6` FOREIGN KEY (`Incantesimo_due`) REFERENCES `incantesimo` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `Vincolo7` FOREIGN KEY (`Runa_chiave`) REFERENCES `runa` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `giocatore`
--
ALTER TABLE `giocatore`
  ADD CONSTRAINT `Vincolo club` FOREIGN KEY (`Club`) REFERENCES `club` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `informazioni_campione`
--
ALTER TABLE `informazioni_campione`
  ADD CONSTRAINT `informazioni_campione_ibfk_1` FOREIGN KEY (`Campione`) REFERENCES `campione` (`Nome`);

--
-- Limiti per la tabella `mossa_campione`
--
ALTER TABLE `mossa_campione`
  ADD CONSTRAINT `mossa_campione_ibfk_1` FOREIGN KEY (`Campione`) REFERENCES `campione` (`Nome`);

--
-- Limiti per la tabella `partita`
--
ALTER TABLE `partita`
  ADD CONSTRAINT `partita_2` FOREIGN KEY (`Campione_usato`) REFERENCES `campione` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_3` FOREIGN KEY (`Evocatore`) REFERENCES `giocatore` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `partita_4` FOREIGN KEY (`Aspetto_usato`) REFERENCES `aspetto_posseduto` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `statistiche_campione`
--
ALTER TABLE `statistiche_campione`
  ADD CONSTRAINT `Vincolo campione` FOREIGN KEY (`Nome_campione`) REFERENCES `campione` (`Nome`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
