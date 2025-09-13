# 📱 Africa Online Stores

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue.svg?logo=flutter)](https://flutter.dev)  
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)  
[![Build](https://img.shields.io/github/actions/workflow/status/Janja-Programmers/africa-online-stores-mobile/flutter.yml?branch=main&label=build&logo=github)](https://github.com/Janja-Programmers/africa-online-stores-mobile/actions)

A **Flutter mobile marketplace app** linking **Vendors** and **Buyers** in Kenya and beyond.  
The app is powered by **ERPNext (Frappe Cloud)** on the backend and built with Flutter’s modern cross-platform framework.

---

## ✨ Features

### 👤 User Registration

- Collects: **Username, Email, Phone Number, Password, User Type (Vendor/Buyer)**
- Checkboxes for **Terms & Conditions** and **Privacy Policy** (embedded dialogs)
- **Strict data privacy compliance** (Google Play + Kenya Data Protection Act)

### 🛍 Buyer Flow

- Browse products listed by Vendors
- Add to cart & place orders
- Provide shipping details
- Contact Vendor directly via phone

### 🏪 Vendor Flow

- Add products (image & video uploads with explicit permission requests)
- Manage stock entries
- View incoming orders
- Optionally mark orders as _Delivered_

### 🔒 Privacy & Compliance

- **ERPNext** backend hosts and processes all user & order data securely on **Frappe Cloud**
- Data is never sold or shared with third parties
- Account deletion wipes all personal data permanently
- Full **Terms & Conditions** and **Privacy Policy** dialogs included

---

## 🛠 Tech Stack

- **Frontend:** [Flutter](https://flutter.dev)
- **Backend:** [ERPNext](https://erpnext.com) (hosted on [Frappe Cloud](https://frappecloud.com))
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router)
- **Networking:** [Dio](https://pub.dev/packages/dio)
- **Storage:** Secure storage for auth, Shared Preferences for caching
- **UI:** Material Design with accessible dialogs for Terms/Policy

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code
- Access to ERPNext backend API

### Installation

```bash
# Clone repository
git clone https://github.com/Janja-Programmers/africa-online-stores-mobile.git
cd africa-online-stores-mobile

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📜 Legal & Compliance

- ✅ Compliant with **Kenya Data Protection Act (2019)**
- ✅ Compliant with **Google Play Developer Policy** (permissions, Data Safety, privacy disclosure)
- ✅ In-app **Terms & Conditions** and **Privacy Policy** (scrollable, accessible, linked to web versions):

  - [Terms & Conditions](https://ownashop.com/terms_and_conditions)
  - [Privacy Policy](https://ownashop.com/privacy_policy)

---

## 📧 Support

For questions, feedback, or data requests:
**Africa Online Stores**
📩 [support@africaonlinestores.com](mailto:support@africaonlinestores.com)

---

## 🙌 Credits

Developed with ❤️ by [Janjaprogrammers](https://janjaprogrammers.com).

---

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

---

⚠️ **Disclaimer**: Africa Online Stores only provides a platform to connect Buyers and Vendors. We are not a payments processor and are not liable for transactions or disputes between users.
