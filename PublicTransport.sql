/*
 Navicat Premium Data Transfer

 Source Server         : PostgreSLQ
 Source Server Type    : PostgreSQL
 Source Server Version : 140001 (140001)
 Source Host           : localhost:5432
 Source Catalog        : transportplatform
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 140001 (140001)
 File Encoding         : 65001

 Date: 17/09/2023 17:35:22
*/


-- ----------------------------
-- Table structure for fare_rates
-- ----------------------------
DROP TABLE IF EXISTS "public"."fare_rates";
CREATE TABLE "public"."fare_rates" (
  "fare_id" int4 NOT NULL DEFAULT nextval('fare_rates_fare_id_seq'::regclass),
  "entry_terminal_id" int4 NOT NULL,
  "exit_terminal_id" int4 NOT NULL,
  "rate" int4 NOT NULL
)
;
ALTER TABLE "public"."fare_rates" OWNER TO "mes";

-- ----------------------------
-- Records of fare_rates
-- ----------------------------
BEGIN;
INSERT INTO "public"."fare_rates" ("fare_id", "entry_terminal_id", "exit_terminal_id", "rate") VALUES (1, 1, 2, 1);
INSERT INTO "public"."fare_rates" ("fare_id", "entry_terminal_id", "exit_terminal_id", "rate") VALUES (2, 2, 1, 1);
COMMIT;

-- ----------------------------
-- Table structure for prepaid_cards
-- ----------------------------
DROP TABLE IF EXISTS "public"."prepaid_cards";
CREATE TABLE "public"."prepaid_cards" (
  "card_id" int4 NOT NULL DEFAULT nextval('prepaid_cards_card_id_seq'::regclass),
  "card_number" varchar(16) COLLATE "pg_catalog"."default" NOT NULL,
  "is_active" bool NOT NULL,
  "is_lock" bool NOT NULL
)
;
ALTER TABLE "public"."prepaid_cards" OWNER TO "mes";

-- ----------------------------
-- Records of prepaid_cards
-- ----------------------------
BEGIN;
INSERT INTO "public"."prepaid_cards" ("card_id", "card_number", "is_active", "is_lock") VALUES (1, '1234567890', 't', 'f');
COMMIT;

-- ----------------------------
-- Table structure for terminals
-- ----------------------------
DROP TABLE IF EXISTS "public"."terminals";
CREATE TABLE "public"."terminals" (
  "terminal_id" int4 NOT NULL,
  "name" varchar(255) COLLATE "pg_catalog"."default" NOT NULL
)
;
ALTER TABLE "public"."terminals" OWNER TO "mes";

-- ----------------------------
-- Records of terminals
-- ----------------------------
BEGIN;
INSERT INTO "public"."terminals" ("terminal_id", "name") VALUES (1, 'Terminal A');
INSERT INTO "public"."terminals" ("terminal_id", "name") VALUES (2, 'Terminal B');
COMMIT;

-- ----------------------------
-- Table structure for transactions
-- ----------------------------
DROP TABLE IF EXISTS "public"."transactions";
CREATE TABLE "public"."transactions" (
  "transaction_id" int4 NOT NULL DEFAULT nextval('transactions_transaction_id_seq'::regclass),
  "card_id" int4 NOT NULL,
  "entry_terminal_id" int4 NOT NULL,
  "exit_terminal_id" int4,
  "entry_time" timestamp(6) NOT NULL,
  "exit_time" timestamp(6),
  "fare_amount" int4
)
;
ALTER TABLE "public"."transactions" OWNER TO "mes";

-- ----------------------------
-- Records of transactions
-- ----------------------------
BEGIN;
INSERT INTO "public"."transactions" ("transaction_id", "card_id", "entry_terminal_id", "exit_terminal_id", "entry_time", "exit_time", "fare_amount") VALUES (1, 1, 1, NULL, '2023-09-17 17:34:37', NULL, NULL);
COMMIT;

-- ----------------------------
-- Primary Key structure for table fare_rates
-- ----------------------------
ALTER TABLE "public"."fare_rates" ADD CONSTRAINT "fare_rates_pkey" PRIMARY KEY ("fare_id");

-- ----------------------------
-- Uniques structure for table prepaid_cards
-- ----------------------------
ALTER TABLE "public"."prepaid_cards" ADD CONSTRAINT "prepaid_cards_card_number_key" UNIQUE ("card_number");

-- ----------------------------
-- Primary Key structure for table prepaid_cards
-- ----------------------------
ALTER TABLE "public"."prepaid_cards" ADD CONSTRAINT "prepaid_cards_pkey" PRIMARY KEY ("card_id");

-- ----------------------------
-- Primary Key structure for table terminals
-- ----------------------------
ALTER TABLE "public"."terminals" ADD CONSTRAINT "terminal_pkey" PRIMARY KEY ("terminal_id");

-- ----------------------------
-- Primary Key structure for table transactions
-- ----------------------------
ALTER TABLE "public"."transactions" ADD CONSTRAINT "transactions_pkey" PRIMARY KEY ("transaction_id");

-- ----------------------------
-- Foreign Keys structure for table fare_rates
-- ----------------------------
ALTER TABLE "public"."fare_rates" ADD CONSTRAINT "fk_entry" FOREIGN KEY ("entry_terminal_id") REFERENCES "public"."terminals" ("terminal_id") ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE "public"."fare_rates" ADD CONSTRAINT "fk_exit" FOREIGN KEY ("exit_terminal_id") REFERENCES "public"."terminals" ("terminal_id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- ----------------------------
-- Foreign Keys structure for table transactions
-- ----------------------------
ALTER TABLE "public"."transactions" ADD CONSTRAINT "fk_card" FOREIGN KEY ("card_id") REFERENCES "public"."prepaid_cards" ("card_id") ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE "public"."transactions" ADD CONSTRAINT "fk_entry" FOREIGN KEY ("entry_terminal_id") REFERENCES "public"."terminals" ("terminal_id") ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE "public"."transactions" ADD CONSTRAINT "fk_exit" FOREIGN KEY ("exit_terminal_id") REFERENCES "public"."terminals" ("terminal_id") ON DELETE RESTRICT ON UPDATE RESTRICT;
