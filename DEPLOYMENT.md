# 🚀 Deployment Guide

Since your application is built with **Vite + React** and uses **Supabase**, hosting is very straightforward.

## Recommended Host: **Vercel** (Best for React/Vite)

### Prerequisites
1.  **GitHub Account**: You need to have your code pushed to a GitHub repository.
2.  **Vercel Account**: Sign up at [vercel.com](https://vercel.com) using your GitHub account.

---

### Step 1: Push Code to GitHub
If you haven't already, push your code to a new GitHub repository:
1.  Create a new repository on GitHub.
2.  Run these commands in your terminal:
    ```bash
    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
    git push -u origin main
    ```

### Step 2: Deploy to Vercel
1.  Go to your **Vercel Dashboard** and click **"Add New..."** -> **"Project"**.
2.  Import your GitHub repository.
3.  **Configure Project**:
    *   **Framework Preset**: It should automatically detect `Vite`.
    *   **Root Directory**: Leave as `./` (default).
4.  **Environment Variables** (CRITICAL STEP):
    *   Expand the **"Environment Variables"** section.
    *   Add the variables from your `.env` file one by one:
        *   `VITE_SUPABASE_URL`: (Paste your URL)
        *   `VITE_SUPABASE_ANON_KEY`: (Paste your Anon Key)
5.  Click **"Deploy"**.

### Step 3: Update Supabase Authentication Settings
Once your site is live (e.g., `https://your-chat-app.vercel.app`), you need to tell Supabase to allow logins from this new URL.

1.  Go to your **Supabase Dashboard** -> **Authentication** -> **URL Configuration**.
2.  Add your new Vercel URL to **Site URL** or **Redirect URLs**.
    *   Example: `https://your-chat-app.vercel.app`
    *   Also add: `https://your-chat-app.vercel.app/**` (wildcard if supported, or just the base URL)
3.  Save changes.

---

## Option 2: Netlify (Alternative)

1.  Sign up at [netlify.com](https://netlify.com).
2.  Click **"Add new site"** -> **"Import from Git"**.
3.  Connect GitHub and select your repository.
4.  **Build Settings**:
    *   **Build Command**: `npm run build`
    *   **Publish Directory**: `dist`
5.  **Environment Variables**:
    *   Click **"Show advanced"** or go to "Site Settings" after deploy.
    *   Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
6.  **Redirects Rule**:
    *   Netlify requires a special file for React Router to work on refresh.
    *   Create a file named `public/_redirects` (no extension) with this content:
        ```text
        /*  /index.html  200
        ```
7.  Deploy and update Supabase URL settings as described above.

---

## ⚠️ Important Notes

*   **Never commit your `.env` file to GitHub.** Your gitignore file should already prevent this, but double-check.
*   **Production Builds**: When you deploy, Vercel/Netlify runs `npm run build`. This creates an optimized version of your app.
*   **Supabase Security**: Now that your app is public, ensure your **Row Level Security (RLS)** policies in Supabase are active so users can only access their own data.
