
![Image description](assets/images/img.png)

The E-Commerce Application is a comprehensive online shopping platform designed to provide users with a seamless and engaging shopping experience. Built with Flutter, this application leverages the Fake Store API to fetch and display a variety of products across different categories. The app includes features such as product search, sorting, filtering, and a fully functional shopping cart integrated with Firebase for user-specific data storage.



The E-Commerce Application is a comprehensive online shopping platform designed to provide users with a seamless and engaging shopping experience. Built with Flutter, this application leverages the Fake Store API to fetch and display a variety of products across different categories. The app includes features such as product search, sorting, filtering, and a fully functional shopping cart integrated with Firebase for user-specific data storage.

API Used in these Project: https://fakestoreapi.com/docs


## Features

Key Features:
1.Product Categories: Easily navigate through various categories like electronics, men's clothing, jewelry, and women's clothing to find desired items quickly.
2.Search Functionality: Efficient search functionality allows users to find products by name or description, enhancing usability.
Sorting Options: Sort products based on price (low to high, high to low) or alphabetically (A-Z, Z-A) to facilitate decision-making.
3.Shopping Cart: Users can add items to their cart, review quantities, and remove items as needed. The cart dynamically updates total prices and quantities.
4.Secure Payment: Integration with secure payment gateways ensures safe transactions for users.
5.User Authentication: Secure user accounts and authentication mechanisms protect user data and provide personalized shopping experiences.
4.Visual Appeal: Cool UI design with attractive visuals and intuitive navigation enhances user engagement and satisfaction.
5.Real-time Updates: Receive notifications and updates on orders, promotions, and new arrivals to stay informed.


## Tech Stack

Frontend: Flutter, Dart
Backend: Firebase Firestore
Networking: HTTP package
State Management: Stateful Widgets
Local Storage: SharedPreferences

## Routes/Links

Main Routes:
Home Screen: The landing page displaying categories.
    Path: /
    Widget: HomeScreen
Category Screen: Displays products in a selected category.
    Path: /category/:categoryName
    Widget: CategoryScreen
    Parameters: categoryName (String)
Product Details: Displays detailed information about a selected product.
    Path: /product/:productId
    Widget: ProductDetailsScreen
    Parameters: productId (int)
Shopping Cart: Displays items in the cart.
    Path: /cart
    Widget: ShoppingCart



Code:

Login:


    Future<void> _login() async {
        final response=await http.post(
      Uri.parse('https://fakestoreapi.com/auth/login'),
      body: {
        'username':_usernameController.text,
        'password':_passwordController.text
      }
    );
    if(response.statusCode==200){
      final data=jsonDecode(response.body);
      final token=data['token'];
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=>Homescreen(token: token,)
          ));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('Login', true);
      await prefs.setString('token', token);
      await _saveUserDetailsToFirestore(token);

    }else{
      setState(() {
        _errorMessage='Invalid Credential';
      });
    }

}

Fetch Product:

    Future<void> _fetchProducts(String category,
    
    List<Product> productList) async {

    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/category/$category'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        productList.clear();
        productList.addAll(data.map((item) => Product.fromJson(item)).toList());
        _allProducts.addAll(productList);
      });
    }}

## Screenshots

ScreenShots:

Login Screen:

<img src=assets/images/login.jpg width=40% height=40%>

Home Screen:
<img src=assets/images/Home.jpg width=40% height=40%>
<img src=assets/images/homescreen.jpg width=40% height=40%>

All Category Screen:
<img src=assets/images/all.jpg width=40% height=40%>

Electronic Screen:
<img src=assets/images/elec.jpg width=40% height=40%>

Jewelery Screen:
<img src=assets/images/jel.jpg width=40% height=40%>

Men's clothing Screen:
<img src=assets/images/men.jpg width=40% height=40%>

Women's clothing Screen:
<img src=assets/images/women.jpg width=40% height=40%>

Cart Screen:
<img src=assets/images/cart.jpg width=40% height=40%>

Checkout Screen:
<img src=assets/images/checkout.jpg width=40% height=40%>

RazorPay Payment Screen:
<img src=assets/images/razorpay payment.jpg width=40% height=40%>
