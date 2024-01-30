SELECT
    c.id,
    c.name,
    cp.user_id,
    last_message.message AS last_message,
    last_message.created_at AS last_message_timestamp,
    COALESCE(um.unread_messages_count, 0) AS unread_messages_count,
    COALESCE(total_messages.total_messages_count, 0) AS total_messages_count,
    c.created_at,
    c.updated_at
FROM chats c
INNER JOIN chat_participants cp ON c.id = cp.chat_id
LEFT JOIN (
    SELECT chat_id, COUNT(*) AS total_messages_count
    FROM messages
    GROUP BY chat_id
) total_messages ON total_messages.chat_id = c.id
LEFT JOIN(
    SELECT messages.chat_id, messages.message, messages.created_at
    FROM messages
    INNER JOIN (
        SELECT chat_id, MAX(messages.created_at) AS max_created_at
        FROM messages
        GROUP BY chat_id
    ) m ON m.chat_id = messages.chat_id AND m.max_created_at = messages.created_at
) last_message ON last_message.chat_id = c.id
LEFT JOIN (
    SELECT chat_id, user_id, COUNT(*) AS unread_messages_count
    FROM unacknowledged_messages
    GROUP BY chat_id, user_id
) um ON c.id = um.chat_id AND cp.user_id = um.user_id
WHERE cp.status = 'active';