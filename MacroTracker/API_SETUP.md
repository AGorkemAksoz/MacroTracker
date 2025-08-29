# 🔐 API Key Setup Guide

This guide explains how to set up the API key for MacroTracker to enable nutrition data fetching.

## �� Prerequisites

- Xcode 15.0 or later
- CalorieNinjas API key (free account)

## �� Step-by-Step Setup

### Step 1: Get Your API Key

1. Visit [CalorieNinjas](https://calorieninjas.com/)
2. Sign up for a free account
3. Navigate to your dashboard
4. Copy your API key

### Step 2: Create Secrets.plist

1. **Open Xcode** and your MacroTracker project
2. **Right-click** on the project root folder (MacroTracker folder)
3. Select **"New File..."**
4. Choose **"Property List"** under Resource section
5. Name it exactly: `Secrets.plist`
6. Make sure it's added to your **MacroTracker** target
7. Click **"Create"**

### Step 3: Add Your API Key

**Option A: Using Xcode Property List Editor**
1. Open `Secrets.plist`
2. Click the `+` button next to "Root"
3. Add a new key: `API_KEY`
4. Set the type to `String`
5. Enter your CalorieNinjas API key as the value

**Option B: Using Text Editor**
Replace the contents of `Secrets.plist` with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>API_KEY</key>
    <string>your_calorieninjas_api_key_here</string>
</dict>
</plist>
```

### Step 4: Verify Security

Ensure your `.gitignore` file includes:
```gitignore
# API Keys and Secrets
Secrets.plist
```

This prevents your API key from being committed to version control.

## ✅ Verification

1. **Build the project** (⌘+B)
2. **Run the app** (⌘+R)
3. **Test the search functionality** - try searching for a food item
4. If you see nutrition data, the setup is successful!

## 🐛 Troubleshooting

### Error: "API Key not found"
- ✅ Check that `Secrets.plist` exists in the project root
- ✅ Verify the key name is exactly `API_KEY` (case sensitive)
- ✅ Ensure the file is added to your target
- ✅ Clean build folder (Shift+⌘+K) and rebuild

### Error: "fatalError"
- ✅ Double-check your `Secrets.plist` format
- ✅ Make sure the file is included in your app bundle
- ✅ Verify the API key is valid

### No Data Loading
- ✅ Check your internet connection
- ✅ Verify your API key is active
- ✅ Check CalorieNinjas service status

## 🔧 For Other Developers

If someone else wants to run this project:

1. **Clone the repository**
2. **Follow this setup guide** to create their own `Secrets.plist`
3. **Get their own API key** from CalorieNinjas
4. **Build and run**

## 📊 API Usage

- **Service**: CalorieNinjas Nutrition API
- **Rate Limit**: 10,000 requests per month (free tier)
- **Data**: Comprehensive nutrition information for foods
- **Format**: JSON responses

## ⚠️ Security Notes

- 🔒 Never commit `Secrets.plist` to version control
- 🔒 Each developer needs their own API key
- �� The app will crash if the API key is missing
- 🔒 API keys are stored locally and not transmitted unnecessarily

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify your CalorieNinjas account status
3. Ensure your API key has sufficient credits

---

**Happy coding! 🎉**