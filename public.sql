CREATE OR REPLACE FUNCTION mail_new (client_id u64, oid u64, mail_id u64, ctime u64, password_hash bytea)
  RETURNS u64
  LANGUAGE plpgsql
  AS $$
DECLARE
  user_id u64;
BEGIN
  SELECT uid INTO user_id
  FROM user_mail
  WHERE user_mail.oid = mail_new.oid
    AND user_mail.mail_id = mail_new.mail_id;
  IF user_id IS NULL THEN
    SELECT uid INTO user_id
    FROM user_mail
    WHERE user_mail.mail_id = mail_new.mail_id
    ORDER BY id
    LIMIT 1;
    IF (user_id IS NULL) OR EXISTS (
    SELECT 1
    FROM user_mail
    WHERE mail_new.oid = user_mail.oid AND uid = user_id) THEN
      SELECT nextval('uid'::regclass) INTO user_id;
      INSERT INTO user_mail (oid, uid, mail_id)
        VALUES (oid, user_id, mail_id);
    END IF;
  END IF;
  INSERT INTO u.log (client_id, oid, uid, ctime, action, val)
    VALUES (client_id, oid, user_id, ctime, 1, password_hash);
  INSERT INTO u.log (client_id, oid, uid, ctime, action, val)
    VALUES (client_id, oid, user_id, ctime, 2, mail_id);
  INSERT INTO user_password (oid, uid, hash, ctime)
    VALUES (oid, user_id, password_hash, ctime)
  ON CONFLICT (oid, uid)
    DO UPDATE SET hash = password_hash, user_password.ctime = mail_new.ctime;
  RETURN user_id;
END;
$$;
