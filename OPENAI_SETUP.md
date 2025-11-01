# AI Assistant Setup Guide

## Environment Configuration

This project uses environment variables to securely store sensitive API keys.

### Setup Instructions

1. **Create your `.env` file:**
   - Copy `.env.example` to create your own `.env` file:
     ```bash
     cp .env.example .env
     ```

2. **Add your OpenAI API Key:**
   - Open the `.env` file
   - Replace `your_openai_api_key_here` with your actual OpenAI API key:
     ```
     OPENAI_API_KEY=sk-proj-YOUR_ACTUAL_KEY_HERE
     ```

3. **Important Security Notes:**
   - The `.env` file is **already added to `.gitignore`** and will NOT be committed to GitHub
   - Never share your API keys publicly
   - Never commit the `.env` file to version control
   - Keep your API keys secure

### Getting an OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key and paste it in your `.env` file

### Features Using OpenAI

The AI Assistant is integrated in two places:

1. **Inbox/Chats Screen**: 
   - Floating bot button opens AI chat
   - General assistance about app features

2. **Contact Us Screen**:
   - AI Assistant card at the top
   - Contextual help and support queries

### Troubleshooting

If you see errors about missing API key:
- Ensure `.env` file exists in the project root
- Check that `OPENAI_API_KEY` is properly set in `.env`
- Restart the app after adding/changing the key
- Make sure the `.env` file is listed in `pubspec.yaml` assets

### File Structure

```
project-root/
├── .env                    # Your local environment variables (not in git)
├── .env.example           # Template file (safe to commit)
├── .gitignore            # Ensures .env is not committed
└── lib/
    └── services/
        └── openai/
            └── openai_service.dart  # Reads from environment variables
```
