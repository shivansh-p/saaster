
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Records of plan_features
-- ----------------------------
DELETE FROM plan_features;
INSERT INTO `plan_features` VALUES (1, 'Planning', '', 1, 1, now());
INSERT INTO `plan_features` VALUES (2, 'Beautiful gantt charts', 'A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.', 0, 2, now());
INSERT INTO `plan_features` VALUES (3, 'Tasks', 'The quick, brown fox jumps over a lazy dog. DJs flock by when MTV ax quiz prog. Junk MTV quiz graced by fox whelps. Bawds jog, flick quartz, vex nymphs.', 0, 3, now());
INSERT INTO `plan_features` VALUES (4, 'Users', 'Waltz, bad nymph, for quick jigs vex! Fox nymphs grab quick-jived waltz. Brick quiz whangs jumpy veldt fox. Bright vixens jump; dozy fowl quack.', 0, 4, now());
INSERT INTO `plan_features` VALUES (5, 'Dependencies', 'Quick wafting zephyrs vex bold Jim. Quick zephyrs blow, vexing daft Jim.', 0, 5, now());
INSERT INTO `plan_features` VALUES (6, 'Management', '', 1, 6, now());
INSERT INTO `plan_features` VALUES (7, 'Your team can update their progress', 'Sex-charged fop blew my junk TV quiz. How quickly daft jumping zebras vex. Two driven jocks help fax my big quiz. Quick, Baz, get my woven flax jodhpurs!', 0, 7, now());
INSERT INTO `plan_features` VALUES (8, 'Daily email reminders', '\"Now fax quiz Jack!\" my brave ghost pled. Five quacking zephyrs jolt my wax bed. Flummoxed by job, kvetching W. zaps Iraq. Cozy sphinx waves quart jug of bad milk.', 0, 8, now());
INSERT INTO `plan_features` VALUES (9, 'Simple task list views', 'A very bad quack might jinx zippy fowls. Few quips galvanized the mock jury box. Quick brown dogs jump over the lazy fox.', 0, 9, now());
INSERT INTO `plan_features` VALUES (10, 'Time Tracking', '', 1, 10, now());
INSERT INTO `plan_features` VALUES (11, 'Manual time entry', 'The jay, pig, fox, zebra, and my wolves quack! Blowzy red vixens fight for a quick jump.', 0, 11, now());
INSERT INTO `plan_features` VALUES (12, 'Reporting', 'Joaquin Phoenix was gazed by MTV for luck. A wizard’s job is to vex chumps quickly in fog. Watch \"Jeopardy!\", Alex Trebeks fun TV quiz game.', 0, 12, now());
INSERT INTO `plan_features` VALUES (13, 'Early detection of hours going over budget', 'Woven silk pyjamas exchanged for blue quartz. Brawny gods just ', 0, 13, now());

-- ----------------------------
-- Records of plan_features_trans
-- ----------------------------
DELETE FROM plan_features_trans;
INSERT INTO `plan_features_trans` VALUES (1, 1, 2, 'Planen', NULL, now());
INSERT INTO `plan_features_trans` VALUES (2, 2, 2, 'Schöne Gantt Charts', 'Eine wunderbare Gelassenheit hat von meiner ganzen Seele Besitz ergriffen, wie diese süßen Frühlingsmorgen, die ich mit ganzem Herzen genieße.', now());
INSERT INTO `plan_features_trans` VALUES (3, 3, 2, 'Aufgaben', 'Der schnelle, braune Fuchs springt über den faulen Hund. DJs strömen vorbei, wenn MTV ax quiz prog. Schrott-MTV-Quiz wird von Fuchs-Welpen beehrt. Bawds joggen, flicken Quarz, vex Nymphen.', now());
INSERT INTO `plan_features_trans` VALUES (4, 5, 2, 'Abhängigkeiten', 'Schnell wehende Zephiren ärgern den kühnen Jim. Schnell wehender Zephir, ärgert den dummen Jim.', now());
INSERT INTO `plan_features_trans` VALUES (5, 6, 2, 'Management', '', now());
INSERT INTO `plan_features_trans` VALUES (6, 7, 2, 'Dein Team kann Fortschritte aktualisieren', 'Sexgeladener Fop hat mein Junk-TV-Quiz vermasselt. Wie schnell verrückte springende Zebras nerven. Zwei getriebene Jocks helfen, mein großes Quiz zu faxen. Schnell, Baz, hol meine gewebte Leinen-Reithose!', now());
INSERT INTO `plan_features_trans` VALUES (7, 8, 2, 'Tägliche E-Mail Erinnerungen', '\"Jetzt Fax-Quiz Jack!\", rief mein tapferer Geist. Fünf quakende Zephiren rütteln an meinem Wachsbett. Verwirrt von der Arbeit, kvetching W. zappt Irak. Gemütliche Sphinx winkt mit einem Krug voll schlechter Milch.', now());
INSERT INTO `plan_features_trans` VALUES (8, 9, 2, 'Einfache Aufgabenlistenansichten', 'Ein sehr schlechter Quacksalber könnte flinke Hühner verhexen. Ein paar Witzeleien brachten die Jury zum Lachen. Schnelle braune Hunde springen über den faulen Fuchs.', now());
INSERT INTO `plan_features_trans` VALUES (9, 10, 2, 'Zeiterfassung', NULL, now());
INSERT INTO `plan_features_trans` VALUES (10, 11, 2, 'Manuelle Zeiterfassung', 'Der Eichelhäher, das Schwein, der Fuchs, das Zebra und meine Wölfe quaken! Aufgeblasene rote Füchse kämpfen um einen schnellen Sprung.', now());
INSERT INTO `plan_features_trans` VALUES (11, 12, 2, 'Berichte erstellen', 'Joaquin Phoenix wurde von MTV als Glücksbringer angesehen. Die Aufgabe eines Zauberers ist es, Dummköpfe schnell im Nebel zu verwirren. Sieh dir \"Jeopardy!\" an, das lustige TV-Quizspiel von Alex Trebek.', now());
INSERT INTO `plan_features_trans` VALUES (12, 13, 2, 'Frühzeitige Erkennung von Stunden, die das Budget überschreiten', 'Pyjama aus gewebter Seide gegen blauen Quarz getauscht. Brawny Götter nur ', now());
INSERT INTO `plan_features_trans` VALUES (13, 4, 2, 'Benutzer', 'Walzer, schlechte Nymphe, für schnelle Jigs vex! Fuchsnymphen schnappen sich den schnell gesprungenen Walzer. Brick Quiz whangs jumpy veldt fox. Helle Füchse springen; dösende Hühner quaken.', now());

-- ----------------------------
-- Records of plan_groups
-- ----------------------------
DELETE FROM plan_groups;
INSERT INTO `plan_groups` VALUES (1, 'Pricing worldwide', NULL, 1, now());

-- ----------------------------
-- Records of plan_groups_trans
-- ----------------------------
DELETE FROM plan_groups_trans;
INSERT INTO `plan_groups_trans` VALUES (1, 1, 2, 'Preise weltweit', now());

-- ----------------------------
-- Records of plan_prices
-- ----------------------------
DELETE FROM plan_prices;
INSERT INTO `plan_prices` VALUES (1, 2, 1, 0.00, 0.00, 7.70, 1, 3, 0);
INSERT INTO `plan_prices` VALUES (2, 2, 3, 0.00, 0.00, 7.70, 1, 3, 0);
INSERT INTO `plan_prices` VALUES (4, 3, 1, 89.00, 800.00, 7.70, 0, 2, 0);
INSERT INTO `plan_prices` VALUES (5, 3, 3, 89.00, 800.00, 7.70, 0, 2, 0);
INSERT INTO `plan_prices` VALUES (7, 4, 1, 129.00, 1100.00, 7.70, 1, 1, 0);
INSERT INTO `plan_prices` VALUES (8, 4, 3, 129.00, 1100.00, 7.70, 1, 1, 0);
INSERT INTO `plan_prices` VALUES (9, 5, 1, 0.00, 0.00, 7.70, 1, 1, 3);
INSERT INTO `plan_prices` VALUES (10, 5, 3, 0.00, 0.00, 7.70, 1, 1, 3);

-- ----------------------------
-- Records of plans
-- ----------------------------
DELETE FROM plans;
INSERT INTO `plans` VALUES (2, 1, 'Free', '3 users + 0 guests\r\nBest for small, personal projects', '<ul><li>1 project</li><li>3 users</li><li>60 task limit</li></ul>', 'Try free', '', 0, 3, 30, 1, 1, now());
INSERT INTO `plans` VALUES (3, 1, 'Standard', 'Up to 10 users\r\nFor teams that need planning and collaboration features.', '<p><strong>Try free for 30 days. Cancel anytime.</strong></p><ul><li>Unlimited projects</li><li>Unlimited tasks</li><li>Add users as needed</li><li>Collaboration and planning features</li></ul>', 'Try standard', '', 1, 10, 30, 0, 2, now());
INSERT INTO `plans` VALUES (4, 1, 'Advanced', 'Up to 30 users\r\nFor teams that need planning and collaboration, + tracking workloads by hours, and advanced project reporting. ', '<p><strong>Including all from Basic plan and:</strong></p><ul><li>Advanced reporting</li><li>Track workloads by hours</li></ul><ul></ul>', 'Try advanced', '', 0, 30, 30, 0, 3, now());
INSERT INTO `plans` VALUES (5, 1, 'Enterprise', 'Bis business for large companies.\r\nUp to 500 users or more - pleas ask for offer', '<ul><li>Unlimited projects</li><li>Unlimited tasks</li><li>Add users as needed no limits</li><li>and much more<br></li></ul>', 'Contact', 'contact/enterprise', 0, 0, 30, 0, 4, now());

-- ----------------------------
-- Records of plans_plan_features
-- ----------------------------
DELETE FROM plans_plan_features;
INSERT INTO `plans_plan_features` VALUES (1, 2, 2, 0, '1', now());
INSERT INTO `plans_plan_features` VALUES (2, 2, 3, 0, '60', now());
INSERT INTO `plans_plan_features` VALUES (3, 2, 4, 0, '3', now());
INSERT INTO `plans_plan_features` VALUES (4, 2, 5, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (5, 2, 7, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (6, 2, 8, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (7, 2, 9, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (8, 2, 11, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (9, 2, 12, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (10, 2, 13, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (11, 3, 2, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (12, 3, 3, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (13, 3, 4, 0, '+1', now());
INSERT INTO `plans_plan_features` VALUES (14, 3, 5, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (15, 3, 7, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (16, 3, 8, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (17, 3, 9, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (18, 3, 11, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (19, 3, 12, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (20, 3, 13, 0, '', now());
INSERT INTO `plans_plan_features` VALUES (21, 4, 2, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (22, 4, 3, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (23, 4, 4, 0, '30', now());
INSERT INTO `plans_plan_features` VALUES (24, 4, 5, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (25, 4, 7, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (26, 4, 8, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (27, 4, 9, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (28, 4, 11, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (29, 4, 12, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (30, 4, 13, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (31, 5, 2, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (32, 5, 3, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (33, 5, 4, 0, 'Unlimited', now());
INSERT INTO `plans_plan_features` VALUES (34, 5, 5, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (35, 5, 7, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (36, 5, 8, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (37, 5, 9, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (38, 5, 11, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (39, 5, 12, 1, '', now());
INSERT INTO `plans_plan_features` VALUES (40, 5, 13, 1, '', now());

-- ----------------------------
-- Records of plans_plan_features_trans
-- ----------------------------
DELETE FROM plans_plan_features_trans;
INSERT INTO `plans_plan_features_trans` VALUES (1, 31, 2, 'Unlimitiert', now());
INSERT INTO `plans_plan_features_trans` VALUES (2, 32, 2, 'Unlimitiert', now());
INSERT INTO `plans_plan_features_trans` VALUES (3, 33, 2, 'Unlimitiert', now());
INSERT INTO `plans_plan_features_trans` VALUES (4, 21, 2, 'Unlimitiert', now());
INSERT INTO `plans_plan_features_trans` VALUES (5, 22, 2, 'Unlimitiert', now());
INSERT INTO `plans_plan_features_trans` VALUES (6, 23, 2, '30', now());

-- ----------------------------
-- Records of plans_trans
-- ----------------------------
DELETE FROM plans_trans;
INSERT INTO `plans_trans` VALUES (1, 2, 2, 'Easy', '3 Benutzer + 0 Gäster\r\nAm besten für kleine, persönliche Projekte', '<ul><li>1 Projekt</li><li>3 Benutzer<br></li><li>Limit von 60 Aufgaben<br></li></ul>', 'Kostenlos testen', NULL, now());
INSERT INTO `plans_trans` VALUES (2, 4, 2, 'Advanced', 'Bis zu 30 Benutzer\r\nFür Teams, die Planung und Zusammenarbeit benötigen, + Verfolgung des Arbeitsaufwands nach Stunden und erweiterte Projektberichte.', '<p>Alles aus Basic und:</p><ul><li>Erweitertes Reporting</li><li>Arbeitsauslastung nach Stunden<br></li></ul>', 'Advanced testen', NULL, now());
INSERT INTO `plans_trans` VALUES (3, 3, 2, 'Standard', 'Bis zu 10 Benutzer \r\nFür Teams, die Funktionen zur Planung und Zusammenarbeit benötigen.', '<p><strong>Testen Sie kostenlos für 30 Tage. Jederzeit kündbar.</strong></p><ul><li>Unbegrenzte Projekte</li><li>Unbegrenzte Aufgaben</li><li>Benutzer nach Bedarf hinzufügen</li><li>Funktionen für Zusammenarbeit und Planung<br></li></ul>', 'Standard testen', NULL, now());
INSERT INTO `plans_trans` VALUES (4, 5, 2, 'Enterprise', 'Großes Geschäft für große Unternehmen.\r\nBis zu 500 Benutzer oder mehr - bitte fragen Sie nach einem Angebot', '<ul><li>Unlimitiert Projekte<br></li><li>Unlimitiert Aufgaben</li><li>Hinzufügen von Benutzern ohne Einschränkung<br></li><li>und vieles mehr<br></li></ul>', 'Kontakt', NULL, now());

SET FOREIGN_KEY_CHECKS = 1;