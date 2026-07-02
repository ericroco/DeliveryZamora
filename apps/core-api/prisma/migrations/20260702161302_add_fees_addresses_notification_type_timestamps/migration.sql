/*
  Warnings:

  - Added the required column `updated_at` to the `client_profiles` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `driver_profiles` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('ORDER_UPDATE', 'PROMO', 'DEBT_ALERT', 'SYSTEM');

-- AlterTable
ALTER TABLE "client_profiles" ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "driver_profiles" ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- AlterTable
ALTER TABLE "notifications" ADD COLUMN     "type" "NotificationType" NOT NULL DEFAULT 'SYSTEM';

-- AlterTable
ALTER TABLE "order_items" ADD COLUMN     "notes" TEXT;

-- AlterTable
ALTER TABLE "orders" ADD COLUMN     "delivery_fee" DECIMAL(10,2) NOT NULL DEFAULT 0,
ADD COLUMN     "service_fee" DECIMAL(10,2) NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "stores" ADD COLUMN     "delivery_fee_rate" DECIMAL(5,2) NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "client_addresses" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "client_addresses_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "client_addresses" ADD CONSTRAINT "client_addresses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
