/*
  Warnings:

  - Added the required column `updated_at` to the `merchant_profiles` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "merchant_profiles" ADD COLUMN     "address" TEXT,
ADD COLUMN     "cover_url" TEXT,
ADD COLUMN     "description" TEXT,
ADD COLUMN     "logo_url" TEXT,
ADD COLUMN     "opening_hours" JSONB,
ADD COLUMN     "phone" TEXT,
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;
