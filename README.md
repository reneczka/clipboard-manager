# Clipboard Manager App for macOS

This Swift project is a macOS application designed to manage clipboard history efficiently. It provides a user-friendly interface to view and manage clipboard entries, enhancing productivity for users who frequently copy and paste content.

## Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Accessing the Application](#accessing-the-application)
  - [Managing Clipboard History](#managing-clipboard-history)


## About the Project

The Clipboard Manager App aims to provide a seamless experience for managing clipboard history on macOS. It allows users to view and organize clipboard entries, making it easier to access previously copied content.

## Features

- **Clipboard History Management**: Automatically saves clipboard entries for easy access.
- **User-Friendly Interface**: Intuitive design for easy navigation and management.
- **Supported Clipboard Formats**: Handles various data types including:
  - **Text**: Plain text entries.
  - **Image**: Image data.
  - **URL**: Web links.
  - **HTML**: HTML content.
  - **RTF**: Rich Text Format.

## Technologies Used

- **Swift**: Core programming language for macOS development.
- **SwiftUI**: Framework for building the user interface.
- **Core Data**: Used for persistent storage of clipboard entries.

## Project Structure

```
ClipboardManager/
├── Services/
│   └── ClipboardHistoryManager.swift - Manages clipboard history logic
├── Views/
│   └── ClipboardHistoryView.swift - SwiftUI view for displaying clipboard history
├── Models/
│   ├── ClipboardEntry.swift - Model for clipboard entries
│   └── ClipboardDataType.swift - Enum for clipboard data types
└── ClipboardManagerApp.swift - Main application entry point
```

## Setup and Installation

### Prerequisites

- macOS with Xcode installed
- Swift 5.0 or later

### Installation

1. **Clone the repository:**

   ```
   git clone https://github.com/reneczka/ClipboardManager.git
   cd clipboard-manager
   ```

2. **Open the project in Xcode:**

   Open `ClipboardManager.xcodeproj` in Xcode.

3. **Build and run the application:**

   Use Xcode to build and run the application on your macOS system.

## Usage

### Accessing the Application

- **Launch the application** from your Applications folder or directly from Xcode.

### Managing Clipboard History

- **View clipboard history** in the main interface.
- **Select and manage entries** as needed.
