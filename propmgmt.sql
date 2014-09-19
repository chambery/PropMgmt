

CREATE TABLE "contracts" ("prop_name" TEXT NOT NULL ,"contract_name" TEXT NOT NULL ,"from_date" TEXT DEFAULT (null) ,"to_date" TEXT,"vendor" TEXT,"website" TEXT,"amount" INTEGER DEFAULT (null) ,"paid_on" TEXT,"notes" TEXT);
INSERT INTO "contracts" VALUES ('1313 Mockingbird Ln', 'insurance', '2014-07-01', '2015-07-01', 'Home Insurance Corp', '', 76000, '2014-07-15', 'some interesting things');
INSERT INTO "contracts" VALUES ('10 Downing St', 'insurance', '2014-07-01', '2015-07-01', 'Insurance Home Corp', '', 76000, '2014-07-15', 'some interesting things');


CREATE TABLE history ("prop_name" TEXT NOT NULL,"item_name" TEXT NOT NULL,"amount" FLOAT ,"date" TEXT NOT NULL,"vendor" TEXT ,"notes" TEXT);
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'rent', 83000.0, '2014-08-01', '', '');
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'HOA', -12500.0, '2014-08-20', '', '');
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'house cleaning', -32000.0, '2014-08-01', 'My Carpet Cleaning', 'Some stuff about cleaning');
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'carpet cleaning', -12500.0, '2014-08-01', 'My Carpet Cleaning', 'Decent job');
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'rent', 135000.0, '2014-09-17', NULL, NULL);
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'rent', 135000.0, '2014-07-14', NULL, NULL);
INSERT INTO "history" VALUES ('1313 Mockingbird Ln', 'rent', 135000.0, '2014-06-03', NULL, NULL);
INSERT INTO "history" VALUES ('10 Downing St', 'rent', 830.0, '2014-08-01', NULL, NULL);


CREATE TABLE "leases" (
	`prop_name`	TEXT NOT NULL,
	`from_date`	TEXT NOT NULL,
	`to_date`	TEXT,
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT
);
INSERT INTO "leases" VALUES ('1313 Mockingbird Ln', '2014-03-01', '2015-03-01', 1);
INSERT INTO "leases" VALUES ('10 Downing St', '2014-08-01', '2014-10-01', 2);


CREATE TABLE `leases_tenants` (
	`lease_id`	INTEGER,
	`tenant_id`	INTEGER
);
INSERT INTO "leases_tenants" VALUES (1, 1);
INSERT INTO "leases_tenants" VALUES (1, 2);
INSERT INTO "leases_tenants" VALUES (2, 3);


CREATE TABLE "tenants" (
	`name`	TEXT NOT NULL,
	`phone`	TEXT,
	`email`	TEXT,
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT
);
INSERT INTO "tenants" VALUES ('Maria McDoughnut', '704-555-1212', 'mmcd@email.com', 1);
INSERT INTO "tenants" VALUES ('Sean McDoughnut', '704-555-1212', 'smcd@email.com', 2);
INSERT INTO "tenants" VALUES ('Bob Smith', '704-555-1212', 'bob.smith@email.com', 3);
