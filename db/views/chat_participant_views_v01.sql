SELECT cp.id,
       cp.user_id,
       cp.chat_id,
       cp.status,
       u.first_name,
       u.last_name
FROM users u
LEFT JOIN chat_participants cp ON cp.user_id = u.id