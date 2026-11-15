local _, ns = ...

local L = {
    DB_LOOKUP = "Spyglass Lookup",
    NPC = "NPC",
    ITEM = "Item",
    QUEST = "Quest",
    SPELL = "Spell/Enchant",
    CLOSE = "Close",
    ENABLED = "Enabled.",
    DISABLED = "Disabled.",
    NO_TARGET = "You don't have a target to look up! (Type /spyglass help for commands)",
    HELP_BASE = "/spyglass - Attempt lookup on your current target",
    HELP_TOGGLE = "/spyglass toggle - Enable / Disable",
    HELP_SETUP = "/spyglass setup - Open database URL setup",
    LOADED = "v%s loaded. /spyglass for options.",
    OPENED_LINK = "Opened database link for: ",
    URL_BLANK = "Saved URL is blank. Database lookups will fail until a URL is set.",
    URL_SAVED = "Database URL updated to: ",
    SETUP_TITLE = "Spyglass Setup",
    SETUP_SUBTITLE = "Enter your custom database URL below:",
    SETUP_SAVE = "Save",
    SETUP_SUGGEST = "Suggest: %s",
}

local spanish = {
    DB_LOOKUP = "Buscar con Spyglass",
    NPC = "PNJ",
    ITEM = "Objeto",
    QUEST = "Misión",
    SPELL = "Hechizo/Encantamiento",
    CLOSE = "Cerrar",
    ENABLED = "Activado.",
    DISABLED = "Desactivado.",
    NO_TARGET = "¡No tienes un objetivo! (Usa /spyglass help para comandos)",
    HELP_BASE = "/spyglass - Buscar tu objetivo actual",
    HELP_TOGGLE = "/spyglass toggle - Activar / Desactivar addon",
    HELP_SETUP = "/spyglass setup - Abrir configuración de URL",
    LOADED = "v%s cargado. Usa /spyglass para opciones.",
    OPENED_LINK = "Enlace de la base de datos abierto para: ",
    URL_BLANK = "La URL guardada está vacía. Las búsquedas fallarán hasta que configures una.",
    URL_SAVED = "URL de la base de datos actualizada a: ",
    SETUP_TITLE = "Configuración de Spyglass",
    SETUP_SUBTITLE = "Introduce la URL de tu base de datos:",
    SETUP_SAVE = "Guardar",
    SETUP_SUGGEST = "Sugerir: %s",
}

local portuguese = {
    DB_LOOKUP = "Buscar no Spyglass",
    NPC = "NPC",
    ITEM = "Item",
    QUEST = "Missão",
    SPELL = "Feitiço/Encantamento",
    CLOSE = "Fechar",
    ENABLED = "Ativado.",
    DISABLED = "Desativado.",
    NO_TARGET = "Você não tem um alvo válido! (Use /spyglass help para os comandos)",
    HELP_BASE = "/spyglass - Buscar o seu alvo atual",
    HELP_TOGGLE = "/spyglass toggle - Ativar / Desativar o addon",
    HELP_SETUP = "/spyglass setup - Abrir a configuração da URL",
    LOADED = "v%s carregado. Use /spyglass para opções.",
    OPENED_LINK = "Link do banco de dados aberto para: ",
    URL_BLANK = "A URL salva está vazia. As buscas vão falhar até você definir uma.",
    URL_SAVED = "URL do banco de dados atualizada para: ",
    SETUP_TITLE = "Configuração do Spyglass",
    SETUP_SUBTITLE = "Insira a URL do banco de dados abaixo:",
    SETUP_SAVE = "Salvar",
    SETUP_SUGGEST = "Sugerir: %s",
}

local TRANSLATIONS = {
    esES = spanish,
    esMX = spanish,
    ptBR = portuguese,
    ptPT = portuguese,
}

for key, text in pairs(TRANSLATIONS[GetLocale()] or {}) do
    L[key] = text
end

ns.L = L
