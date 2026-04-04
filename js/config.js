// ===== VISIT & SMILE — CONFIGURATION =====
// Remplir avec les vraies valeurs après création du projet Supabase

const CONFIG = {
    // Supabase
    SUPABASE_URL: 'https://VOTRE_PROJET.supabase.co',
    SUPABASE_ANON_KEY: 'VOTRE_ANON_KEY',

    // n8n Webhooks
    N8N_BASE_URL: 'https://n8n.votredomaine.com',
    WEBHOOKS: {
        CHATBOT: '/webhook/chatbot',
        NEW_SALE: '/webhook/new-sale',
        NEW_APPOINTMENT: '/webhook/new-appointment',
        PUBLISH_POST: '/webhook/publish-post',
        GENERATE_CONTENT: '/webhook/generate-content',
    },

    // App
    APP_NAME: 'Visit & Smile',
    AI_NAME: 'Deadpool IA',
    DEFAULT_CITY: 'Orléans',
    URSSAF_RATE: 0.22,
};
