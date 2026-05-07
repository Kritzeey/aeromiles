CREATE TABLE pengguna (
  email VARCHAR(100) PRIMARY KEY,
  password VARCHAR(255) NOT NULL,
  salutation VARCHAR(10) NOT NULL CHECK (salutation IN ('Mr.', 'Mrs.', 'Ms.', 'Dr.')),
  first_mid_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  country_code VARCHAR(5) NOT NULL,
  mobile_number VARCHAR(20) NOT NULL,
  tanggal_lahir DATE NOT NULL,
  kewarganegaraan VARCHAR(50) NOT NULL
);

CREATE TABLE tier (
  id_tier VARCHAR(10) PRIMARY KEY,
  nama VARCHAR(50) NOT NULL,
  minimal_frekuensi_terbang INT NOT NULL,
  minimal_tier_miles INT NOT NULL
);

CREATE TABLE penyedia (id SERIAL PRIMARY KEY);

CREATE SEQUENCE nomor_member START 1;

CREATE TABLE member (
  email VARCHAR(100) PRIMARY KEY REFERENCES pengguna (email) ON DELETE CASCADE,
  nomor_member VARCHAR(20) NOT NULL UNIQUE DEFAULT 'M' || lpad(nextval('nomor_member')::text, 4, '0'),
  tanggal_bergabung DATE NOT NULL,
  id_tier VARCHAR(10) NOT NULL REFERENCES tier (id_tier),
  award_miles INT DEFAULT 0,
  total_miles INT DEFAULT 0
);

CREATE TABLE maskapai (
  kode_maskapai VARCHAR(10) PRIMARY KEY,
  nama_maskapai VARCHAR(100) NOT NULL,
  id_penyedia INT NOT NULL REFERENCES penyedia (id) ON DELETE CASCADE
);

CREATE SEQUENCE id_staf START 1;

CREATE TABLE staf (
  email VARCHAR(100) PRIMARY KEY REFERENCES pengguna (email) ON DELETE CASCADE,
  id_staf VARCHAR(20) NOT NULL UNIQUE DEFAULT 'S' || lpad(nextval('id_staf')::text, 4, '0'),
  kode_maskapai VARCHAR(10) NOT NULL REFERENCES maskapai (kode_maskapai) ON DELETE CASCADE
);

CREATE TABLE mitra (
  email_mitra VARCHAR(100) PRIMARY KEY,
  id_penyedia INT NOT NULL UNIQUE REFERENCES penyedia (id) ON DELETE CASCADE,
  nama_mitra VARCHAR(100) NOT NULL,
  tanggal_kerja_sama DATE NOT NULL
);

CREATE TABLE identitas (
  nomor VARCHAR(50) PRIMARY KEY,
  email_member VARCHAR(100) NOT NULL REFERENCES member (email) ON DELETE CASCADE,
  tanggal_habis DATE NOT NULL,
  tanggal_terbit DATE NOT NULL,
  negara_penerbit VARCHAR(50) NOT NULL,
  jenis VARCHAR(30) NOT NULL CHECK (jenis IN ('Paspor', 'KTP', 'SIM'))
);

CREATE SEQUENCE id START 1;

CREATE TABLE award_miles_package (
  id VARCHAR(20) PRIMARY KEY DEFAULT 'AMP-' || lpad(nextval('id')::text, 3, '0'),
  harga_paket DECIMAL(15, 2) NOT NULL,
  jumlah_award_miles INT NOT NULL
);

CREATE TABLE member_award_miles_package (
  id_award_miles_package VARCHAR(20) NOT NULL REFERENCES award_miles_package (id) ON DELETE CASCADE,
  email_member VARCHAR(100) NOT NULL REFERENCES member (email) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  PRIMARY KEY (id_award_miles_package, email_member, timestamp)
);

CREATE TABLE bandara (
  iata_code CHAR(3) PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  kota VARCHAR(100) NOT NULL,
  negara VARCHAR(100) NOT NULL
);

CREATE TABLE claim_missing_miles (
  id SERIAL PRIMARY KEY,
  email_member VARCHAR(100) NOT NULL REFERENCES member (email) ON DELETE CASCADE,
  email_staf VARCHAR(100) REFERENCES staf (email) ON DELETE CASCADE,
  maskapai VARCHAR(10) NOT NULL REFERENCES maskapai (kode_maskapai) ON DELETE CASCADE,
  bandara_asal VARCHAR(3) NOT NULL REFERENCES bandara (iata_code) ON DELETE CASCADE,
  bandara_tujuan VARCHAR(3) NOT NULL REFERENCES bandara (iata_code) ON DELETE CASCADE,
  tanggal_penerbangan DATE NOT NULL,
  flight_number VARCHAR(10) NOT NULL,
  nomor_tiket VARCHAR(20) NOT NULL,
  kelas_kabin VARCHAR(20) NOT NULL CHECK (kelas_kabin IN ('Economy', 'Business', 'First')),
  pnr VARCHAR(10) NOT NULL,
  status_penerimaan VARCHAR(20) NOT NULL DEFAULT 'Menunggu' CHECK (
    status_penerimaan IN ('Menunggu', 'Disetujui', 'Ditolak')
  ),
  timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_klaim UNIQUE (
    email_member,
    flight_number,
    tanggal_penerbangan,
    nomor_tiket
  )
);

CREATE TABLE transfer (
  email_member_1 VARCHAR(100) NOT NULL REFERENCES member (email) ON DELETE CASCADE,
  email_member_2 VARCHAR(100) NOT NULL REFERENCES member (email) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  jumlah INT NOT NULL,
  catatan VARCHAR(255),
  PRIMARY KEY (email_member_1, email_member_2, timestamp),
  CONSTRAINT cek_bukan_diri_sendiri CHECK (email_member_1 != email_member_2)
);

CREATE SEQUENCE kode_hadiah START 1;

CREATE TABLE hadiah (
  kode_hadiah VARCHAR(20) PRIMARY KEY DEFAULT 'RWD-' || lpad(nextval('kode_hadiah')::text, 3, '0'),
  nama VARCHAR(100) NOT NULL,
  miles INT NOT NULL,
  deskripsi TEXT,
  valid_start_date DATE NOT NULL,
  program_end DATE NOT NULL,
  id_penyedia INT NOT NULL REFERENCES penyedia (id) ON DELETE CASCADE
);

CREATE TABLE redeem (
  email_member VARCHAR(100) NOT NULL REFERENCES member (email) ON DELETE CASCADE,
  kode_hadiah VARCHAR(20) NOT NULL REFERENCES hadiah (kode_hadiah) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (email_member, kode_hadiah, timestamp)
);
