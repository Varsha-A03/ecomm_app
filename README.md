# E-commerce Flutter App

## Overview

This E-commerce Flutter app is a responsive, feature-rich mobile and web application designed to simulate an online shopping experience. It includes functionality for browsing products, searching, filtering, sorting, managing a cart, and a wishlist, as well as user authentication.
The app is built using Flutter and integrates the FakeStore API for fetching product and authentication data. It adheres to clean architecture principles by separating UI and business logic wherever applicable. Persistent storage is implemented for cart and wishlist data using shared_preferences.


## Features

### User Authentication
Login functionality with error handling.
Token-based authentication using the FakeStore API.
Login credentials are validated, and tokens are securely stored using shared_preferences.
Logout functionality clears tokens and redirects the user to the login screen.
Note: Since we are using the FakeStore API, the username and password remain static for authentication:
```
    Username: mor_2314
    Password: 83r5^_
```
To access the app, users must use the above credentials.
### Product Listings
Infinite scrolling for products (initially loads 10 products, fetches more on scrolling).
Featured products displayed with details like image, price, and ratings.
```
Important: As the FakeStore API contains only 20 products, infinite scrolling is achieved by reusing the products. This can cause products to reappear multiple times. The same behavior applies to searching, filtering, and sorting. This issue arises because the app is frontend-only and uses the FakeStore API instead of a dedicated backend.
```
### Product Detail Page
Detailed view of the product with description, price, ratings, and reviews.
Simulated product reviews generated dynamically.
### Search, Filter, and Sort
Search products by name.
Filter products by category, price range, and rating.
Sort products by price (low-to-high, high-to-low), popularity (most reviewed), and ratings.
```
Note: Filters applied through the floating button require the user to click on the "Apply Filters" button for the changes to take effect. The interactions might feel slightly slow, but the filters will be applied once the button is clicked.
```
### Cart Functionality
Add products to the cart and update quantities.
Persistent cart data using shared_preferences.
Display cart summary with total price.
Checkout functionality with a form to input user details.
### Wishlist Functionality
Add/remove products to/from the wishlist.
Persistent wishlist data using shared_preferences.
Wishlist items displayed in a grid view.
### Responsive Design
Optimized for different screen sizes (mobile, tablet, desktop).
Uses adaptive grid layouts and other responsive UI elements.
``` 
Note for Emulator Users: The horizontal navigation bar for categories must be dragged manually on PCs instead of scrolling.
```
### Clean Architecture
Separation of UI and business logic into different folders.
Use of ChangeNotifier for state management (Provider package).
### Theming
    •	Custom color palette: 
    o	Black: #000000
    o	Beige: #F6ECE3
    o	White: #FFFFFF
    o	Brown: #91766E

## Folder Structure
```
ecomm_app/
│
├── lib/
│   ├── components/
│   │   ├── cart_item.dart
│   │   ├── product_card.dart
│   │
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── homepage.dart
│   │   ├── product_detail_page.dart
│   │   ├── cart_page.dart
│   │   ├── wishlist_page.dart
│   │   ├── checkout_page.dart
│   │
│   ├── providers/
│   │   ├── cart_provider.dart
│   │   ├── wishlist_provider.dart
│   │
│   ├── utils/
│   │   ├── api_service.dart
│   │
│   └── main.dart
│
├── assets/
│   └── images/
│       ├── background.png
│       └── ...
│
└── pubspec.yaml

```

## Dependencies

Add the following dependencies to your pubspec.yaml file:
dependencies:  
```    
    flutter:  
        sdk: flutter  
    provider: ^6.0.5  
    shared_preferences: ^2.1.0  
    http: ^0.15.0   
```

## Setup Instructions

### Android Emulator
The app runs seamlessly on the Android emulator with the default Flutter setup.

### Chrome Browser
To run the app on a web browser, execute the following commands:
1. Switch to the stable flutter channel:
    ``` 
    flutter channel stable
    ```
2. Upgrade flutter
    ```
    flutter upgrade
    ```
3. Enable web support
    ```
    flutter config --enable-web
    ```
4. Run the app on chrome
    ```
    flutter run -d chrome
    ```

### General Setup
1. Clone the Repository:
    ```
    git clone <repository-url>
    cd ecomm_app
    ```
2. Install Dependencies:
    ```
    flutter pub get
    ```
3. Add API KEY (if required):
    If the FakeStore API requires an API key, add it in api_service.dart.
4. Run the App:
    ```
    flutter run
    ```

## Key Code Highlights

### Persistent Cart and Wishlist
Implemented using shared_preferences for saving and retrieving data:  
Cart: ```cart_provider.dart ```   
Wishlist: ```wishlist_provider.dart```    

### Responsive Design
Used MediaQuery to detect screen width and adjust UI:
```
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isDesktop = screenWidth > 1024;
```

### API Integration
Fetching products and authenticating users via the FakeStore API:  
Fetch Products: ``` ApiService.fetchAllProducts()  ```  
Login User: ``` ApiService.loginUser(email, password)  ```

### Clean Architecture
UI Layer: Files in ```/pages``` and ```/components``` folders.
Business Logic Layer: Files in ```/providers``` and ```/utils``` folders.

## Screenshots - Andriod Emulator

### Login Page
![Login Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorLogin.png)

### Login Fail Image
![Login Success Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorLoginFail.png)

### Login Successful Image
![Login Success Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorLoginPass.png)

### Home Page
![Home Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorHomePage.png)

### Product Detail Page
![Product Detail Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorProductPage.png)

### Search Functionality
![Searching Products Screenshot](./assets/screenshots/emulatorScreenshots/emulatorSearching.png)

### Sort Functionality
![Sorting Products Screenshot](./assets/screenshots/emulatorScreenshots/emulatorSorting.png)

### Filter Functionality
![Filtering Products Screenshot](./assets/screenshots/emulatorScreenshots/emulatorFiltering.png)

### Filter Reset Functionality
![Filtering Products Screenshot](./assets/screenshots/emulatorScreenshots/emulatorFiltersReset.png)

### Categories 
![Categories Screenshot](./assets/screenshots/emulatorScreenshots/emulatorCategory.png)

### Cart Page
![Cart Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorCartPage.png)

### Checkout Page
![Checkout Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorCheckoutPass.png)

### Drawer Page
![Drawer Screenshot](./assets/screenshots/emulatorScreenshots/emulatorDrawer.png)

### Wishlist Page
![Wishlist Page Screenshot](./assets/screenshots/emulatorScreenshots/emulatorWishlist.png)

## Screenshots - Chrome 

### Login Page
![Login Page Screenshot](./assets/screenshots/chromeScreenshots/chromeLogin.png)

### Login Fail Image
![Login Success Page Screenshot](./assets/screenshots/chromeScreenshots/chromeLoginFail.png)

### Login Successful Image
![Login Success Page Screenshot](./assets/screenshots/chromeScreenshots/chromeLoginPass.png)

### Home Page
![Home Page Screenshot](./assets/screenshots/chromeScreenshots/chromeProductsPage.png)

### Product Detail Page
![Product Detail Page Screenshot](./assets/screenshots/chromeScreenshots/chromeProductDetailPage.png)

### Search Functionality
![Searching Products Screenshot](./assets/screenshots/chromeScreenshots/chromeSearching.png)

### Sort Functionality
![Sorting Products Screenshot](./assets/screenshots/chromeScreenshots/chromeSorting2.png)

### Filter Functionality
![Filtering Products Screenshot](./assets/screenshots/chromeScreenshots/chromeFiltering.png)

### Cart Page
![Cart Page Screenshot](./assets/screenshots/chromeScreenshots/chromeCartPage.png)

### Checkout Page
![Checkout Page Screenshot](./assets/screenshots/chromeScreenshots/chromeCheckoutPage%20(2).png)

### Drawer Page
![Drawer Screenshot](./assets/screenshots/chromeScreenshots/chromeDrawer.png)

### Wishlist Page
![Wishlist Page Screenshot](./assets/screenshots/chromeScreenshots/chromeWishlistPage.png)

## Future Improvements
    •	Add animations for smoother UI transitions.
    •	Improve accessibility by supporting multiple languages.
    •	Add test cases for components and providers.
