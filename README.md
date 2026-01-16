# Secure Chat App

A modern, secure one-on-one chat web application built with React and Supabase. Features real-time messaging, user authentication, and admin panel capabilities.

## 🚀 Features

### Core Features
- **User Authentication**: Secure signup/login with email and password
- **Real-time Messaging**: Instant message delivery using Supabase real-time subscriptions
- **Private Conversations**: End-to-end private one-on-one chats
- **User Management**: View all registered users and start conversations
- **Admin Panel**: Comprehensive admin dashboard with statistics and user management
- **Responsive Design**: Works seamlessly on desktop and mobile devices

### Security Features
- **Row Level Security (RLS)**: Database-level security policies
- **Input Sanitization**: XSS protection for all user inputs
- **Secure Authentication**: Supabase Auth with proper session management
- **Admin Controls**: Admin-only access to sensitive features

### UI/UX Features
- **Modern Design**: Clean, WhatsApp-like interface
- **Loading States**: Smooth loading indicators for all async operations
- **Error Handling**: User-friendly error messages
- **Search Functionality**: Filter users by username
- **Message Timestamps**: Human-readable time formatting
- **Typing Indicators**: Visual feedback for user interactions

## 🛠️ Tech Stack

- **Frontend**: React 18 with modern JavaScript (ES6+)
- **Styling**: Tailwind CSS (via CDN)
- **Backend**: Supabase (Database, Auth, Real-time)
- **Build Tool**: Vite
- **Routing**: React Router v6
- **State Management**: React Hooks & Context API

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v16 or higher)
- **npm** (v8 or higher) or **yarn** (v1.22 or higher)
- **Git** for version control

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd my-chat-app
```

### 2. Install Dependencies

```bash
npm install
```

or if you're using yarn:

```bash
yarn install
```

### 3. Set Up Supabase

#### Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign up and create a new project
3. Note your project URL and anon key from Settings > API

#### Create Database Tables

Run the following SQL in your Supabase SQL Editor:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create conversations table
CREATE TABLE conversations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user1_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_message_at TIMESTAMP WITH TIME ZONE,
  UNIQUE (user1_id, user2_id)
);

-- Create messages table
CREATE TABLE messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  message_text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE
);

-- Create indexes for better performance
CREATE INDEX idx_conversations_user1 ON conversations(user1_id);
CREATE INDEX idx_conversations_user2 ON conversations(user2_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

#### Set Up Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Profiles table policies
CREATE POLICY "Users can view all profiles" ON profiles
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Conversations table policies
CREATE POLICY "Users can view own conversations" ON conversations
  FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create conversations" ON conversations
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can delete own conversations" ON conversations
  FOR DELETE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Messages table policies
CREATE POLICY "Users can view messages in own conversations" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM conversations 
      WHERE conversations.id = messages.conversation_id 
      AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
  );

CREATE POLICY "Users can insert messages in own conversations" ON messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM conversations 
      WHERE conversations.id = messages.conversation_id 
      AND (conversations.user1_id = auth.uid() OR conversations.user2_id = auth.uid())
    )
    AND auth.uid() = sender_id
  );

CREATE POLICY "Users can delete own messages" ON messages
  FOR DELETE USING (auth.uid() = sender_id);

-- Admin override policies
CREATE POLICY "Admins can do everything on profiles" ON profiles
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = TRUE
    )
  );

CREATE POLICY "Admins can do everything on conversations" ON conversations
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = TRUE
    )
  );

CREATE POLICY "Admins can do everything on messages" ON messages
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = TRUE
    )
  );
```

#### Create a Trigger for Profile Creation

```sql
-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, email, is_admin)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || substr(NEW.id::text, 1, 8)),
    NEW.email,
    FALSE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 4. Configure Environment Variables

Create a `.env` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

Replace the values with your actual Supabase project URL and anon key.

### 5. Run the Development Server

```bash
npm run dev
```

or with yarn:

```bash
yarn dev
```

The application will be available at `http://localhost:5173`

## 📱 Usage

### For Regular Users
1. **Sign Up**: Create an account with email, password, and username
2. **Login**: Access your account with your credentials
3. **View Users**: See all registered users (except yourself)
4. **Start Chatting**: Click on any user to start a conversation
5. **Real-time Messaging**: Send and receive messages instantly

### For Admin Users
1. **Access Admin Panel**: Click the "Admin Panel" button from the user list
2. **View Statistics**: Monitor total users, conversations, and messages
3. **Manage Users**: View all users and delete accounts if needed
4. **Monitor Conversations**: View all conversations in the system

## 🚀 Deployment

### Deploy to Vercel

1. Push your code to GitHub
2. Connect your GitHub repository to Vercel
3. Add your environment variables in Vercel dashboard
4. Deploy automatically

### Deploy to GitHub Pages

1. Build the application:
   ```bash
   npm run build
   ```

2. Deploy to GitHub Pages using GitHub Actions or manually

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_SUPABASE_URL` | Your Supabase project URL | Yes |
| `VITE_SUPABASE_ANON_KEY` | Your Supabase anonymous key | Yes |

### Customization

- **Styling**: Modify Tailwind classes in components
- **Colors**: Update color schemes in component files
- **Features**: Extend functionality in service files

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Project Structure

```
my-chat-app/
├── src/
│   ├── components/
│   │   ├── Auth/
│   │   │   ├── Login.jsx
│   │   │   └── Signup.jsx
│   │   ├── Chat/
│   │   │   ├── ChatWindow.jsx
│   │   │   ├── MessageBubble.jsx
│   │   │   └── MessageInput.jsx
│   │   ├── Users/
│   │   │   ├── UserList.jsx
│   │   │   └── UserCard.jsx
│   │   └── Admin/
│   │       └── AdminPanel.jsx
│   ├── context/
│   │   └── AuthContext.jsx
│   ├── services/
│   │   └── supabase.js
│   ├── utils/
│   │   └── helpers.js
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── .env
├── .env.example
├── index.html
├── package.json
├── vite.config.js
└── README.md
```

## 🔒 Security Considerations

- **RLS Policies**: All database operations are protected by Row Level Security
- **Input Validation**: All user inputs are validated and sanitized
- **Admin Controls**: Sensitive operations require admin privileges
- **Session Management**: Secure authentication using Supabase Auth

## 🐛 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Check your Supabase URL and keys in `.env`
   - Ensure RLS policies are correctly set up

2. **Real-time Updates Not Working**
   - Verify Realtime is enabled in your Supabase project
   - Check your internet connection

3. **Build Errors**
   - Ensure all dependencies are installed
   - Check Node.js version compatibility

### Getting Help

- Check the [Supabase Documentation](https://supabase.com/docs)
- Review the [React Documentation](https://react.dev)
- Open an issue in the repository

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Supabase](https://supabase.com) for the amazing backend-as-a-service platform
- [Tailwind CSS](https://tailwindcss.com) for the utility-first CSS framework
- [Vite](https://vitejs.dev) for the fast build tool
- [React](https://react.dev) for the powerful UI library
