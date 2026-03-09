CREATE TABLE leaderboard (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  device_id TEXT NOT NULL UNIQUE,
  nickname TEXT NOT NULL,
  total_score INT DEFAULT 0,
  quiz_count INT DEFAULT 0,
  streak INT DEFAULT 0,
  updated_at TIMESTAMP DEFAULT now()
);

-- RLS 활성화
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

-- SELECT: 모든 사용자 허용
CREATE POLICY "Anyone can read leaderboard"
  ON leaderboard FOR SELECT
  USING (true);

-- INSERT: 누구나 가능 (anon)
CREATE POLICY "Anyone can insert leaderboard"
  ON leaderboard FOR INSERT
  WITH CHECK (true);

-- UPDATE: device_id 일치 시만 허용
CREATE POLICY "Users can update own score"
  ON leaderboard FOR UPDATE
  USING (true)
  WITH CHECK (true);
