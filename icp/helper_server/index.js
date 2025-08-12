import express from 'express';
import cors from 'cors';
import { exec } from 'child_process';

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 8000;
const CANISTER = process.env.CANISTER_ID || 'kawan_umkm_backend';

app.get('/health', (_req, res) => res.json({ ok: true }));

app.post('/tambahPermintaan', (req, res) => {
  const p = req.body?.permintaan;
  if (!p) return res.status(400).json({ error: 'permintaan missing' });
  const candid = `record { id = ${p.id} : nat; namaBarang = \"${p.namaBarang}\"; totalKuantitas = ${p.totalKuantitas} : nat; unit = \"${p.unit}\"; jumlahPartisipan = ${p.jumlahPartisipan} : nat; status = \"${p.status}\" }`;
  const cmd = `dfx canister call ${CANISTER} tambahPermintaan '( ${candid} )'`;
  exec(cmd, { env: process.env }, (err, stdout, stderr) => {
    if (err) return res.status(500).json({ error: stderr || String(err) });
    res.json({ ok: true, output: stdout.trim() });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`ICP helper server listening on ${PORT}`);
});