SELECT m.id,
       m.chat_id,
       m.message,
       cp.user_id,
       m.message_type,
       m.created_at
FROM messages m
INNER JOIN chat_participants cp ON m.chat_participant_id = cp.id