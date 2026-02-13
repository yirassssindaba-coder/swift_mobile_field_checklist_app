# Mock Server Spec (Opsional)

Jika kamu ingin benar-benar mengirim laporan ke backend, aktifkan `AppConfig.baseURL` lalu sediakan endpoint sederhana:

## GET /api/jobs
Return JSON array seperti `MobileFieldChecklistApp/Resources/sample_jobs.json`.

## POST /api/reports
Terima JSON payload:
- `id`, `jobId`, `jobTitle`, `createdAt`
- `items` (checked + noteIfUnchecked)
- `notes`
- `location`
- `attachments` (base64 image/jpeg)

Return HTTP 200/201 saat sukses.

> Catatan: Payload foto adalah base64. Untuk produksi, sebaiknya pakai upload multipart + object storage.
