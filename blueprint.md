
# SmartList App Blueprint

## Overview

SmartList is a Flutter application that allows users to create, manage, and categorize shopping lists. The app provides an estimated total price for each list and for each category, helping users to budget their shopping trips. Data is stored locally on the device.

## Project Outline

### Style, Design, and Features

*   **Theme:** A modern, custom Material 3 theme with distinct, harmonious color schemes for both light and dark modes. The design emphasizes clarity, visual appeal, and a high-quality user experience.
*   **Color Palette:** A primary seed color generates a rich palette of accent colors used consistently across all components (AppBars, FABs, text fields, etc.).
*   **Typography:** Enhanced typography with larger, bolder titles for better hierarchy and readability. Body text is clean and legible.
*   **Layout:** Refined, spacious, and responsive layouts for all screens, ensuring an intuitive and aesthetically pleasing experience on mobile and web.
*   **Core Feature:** Create and manage categorized shopping lists.
*   **Categorization:** Lists can be assigned to custom categories.
*   **Pricing:**  Estimated total price for each shopping list with the Philippine Peso sign (₱).
*   **Category Totals:** The main page displays a subtotal for each category, giving a clear overview of spending.
*   **Sample Data:** For new users, the app comes pre-populated with sample lists (e.g., "Groceries", "Electronics") to demonstrate its features.
*   **Data Persistence:** Shopping lists are saved locally on the device.
*   **Contextual Hints:** The app provides helpful placeholder text and suggestions within input fields to guide the user.
*   **Validation:** Input fields for critical information like list name and category are validated to prevent saving empty lists.
*   **Logo:** The app has a proper launch screen and app icon. The main page app bar displays a clean, centered title.

## Current Request: Add Sample Data and Category Totals

### Plan

1.  **Implement Sample Data:**
    *   In `ShoppingListProvider`, modify the `_loadLists` method to check if the loaded list is empty. If so, populate it with sample shopping lists (e.g., for "Groceries" and "Electronics").

2.  **Display Category Totals:**
    *   In the `ShoppingListPage`, calculate the total price for all lists within each category.
    *   Update the `ExpansionTile` for each category to display this calculated total next to the category name, providing a clear subtotal.

3.  **Update GitHub and Rebuild APK:**
    *   Commit and push the changes to the GitHub repository.
    *   Run the `flutter build apk` command to generate the final application package.
