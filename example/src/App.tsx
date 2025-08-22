import { useEffect, useState } from 'react';
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  Image,
  ActivityIndicator,
  SafeAreaView,
  Alert,
  DeviceEventEmitter,
} from 'react-native';
import {
  ArthPayMerchant,
  CreateOrderRequest,
  CustomerModel,
  OrderModel,
  ArthpaySdkView
} from 'arthpay-sdk';

const CLIENT_ID = "AP_DEV_79LNneDWVA8xXWwMa3rPbp42ki85b0EPIH2J2kAes";
const CLIENT_SECRET = "Y/Ttg62Ut08ghSHVmOsQ/w==";

const App = () => {
  const [link, setLink] = useState("");
  const [showWebView, setShowWebView] = useState(false);
  const [loading, setLoading] = useState(false);

  const paymentInitial = async () => {
    try {
      setLoading(true);
      const arthpay = new ArthPayMerchant(CLIENT_ID, CLIENT_SECRET);

      const order_info = new OrderModel();
      order_info.setOrderInfo("1231231");
      order_info.setCurrency("INR");
      order_info.setAmount("8000");

      const customerDetails = new CustomerModel();
      customerDetails.setFirstName("John");
      customerDetails.setLastName("Doe");
      customerDetails.setChAddrStreet("John Nagar Road");
      customerDetails.setChAddrCity("Mulund");
      customerDetails.setChAddrState("Maharashtra");
      customerDetails.setChAddrZip("4000001");
      customerDetails.setChEmail("support@arthpay.com");
      customerDetails.setChMobile("+919876543210");

      const orderRequest = new CreateOrderRequest(customerDetails, order_info, "");

      let response = await arthpay.createOrder(orderRequest);
      console.log("response====================", response)
      let parsedResponse = JSON.parse(response);
      console.log("parsedResponse====================", parsedResponse)
      const url = parsedResponse?.obj;
      console.log("url====================", url)
      if (url) {
        setLink(url);
        setShowWebView(true);
      }
    } catch (error) {
      console.error("Error initiating payment:", error);
      Alert.alert("Error", "Something went wrong while initiating the payment.");
    } finally {
      setLoading(false);
    }
  };
useEffect(() => {
  const sub = DeviceEventEmitter.addListener('ArthpaySdkEvent', (event) => {
    if (event?.status === 'failed' || event?.status === 'unknown') {
      setShowWebView(false); 
    }
  });

  return () => sub.remove();
}, []);




  // const handleNavigation = (event: any) => {
  //   const url = event.url;
  //   console.log("event.url================", url);

  //   if (url.includes("/ordercallback")) {
  //     const hasTxnData = url.includes("txnData=");
  //     console.log("hasTxnData================", hasTxnData);

  //     if (!hasTxnData) {
  //       Alert.alert("Error", "No txnData found in callback URL.");
  //       setShowWebView(false);
  //       return false;
  //     }

  //     try {
  //       const txnDataEncoded = url.split("txnData=")[1];

  //       const cleanedTxnData = decodeURIComponent(txnDataEncoded.split("&")[0]);

  //       const decodedString = atob(cleanedTxnData);
  //       const txnDataJson = JSON.parse(decodedString);

  //       console.log("Decoded txnData:", txnDataJson);

  //       if (txnDataJson.status === "02") {
  //         Alert.alert("Success", "Payment successful!");
  //       } else {
  //         Alert.alert("Failed", "Payment failed or cancelled.");
  //       }

  //     } catch (error) {
  //       console.error("Decoding error:", error);
  //       Alert.alert("Error", "Failed to decode payment response.");
  //     }

  //     setShowWebView(false);
  //     return false;
  //   }

  //   if (
  //     url.startsWith("upi://") ||
  //     url.startsWith("tez://") ||
  //     url.startsWith("phonepe://") ||
  //     url.startsWith("paytmmp://")
  //   ) {
  //     Linking.canOpenURL(url)
  //       .then((supported) => {
  //         if (supported) {
  //           Linking.openURL(url);
  //         } else {
  //           Alert.alert("Error", "No app found to handle this payment.");
  //         }
  //       })
  //       .catch((err) => {
  //         console.error("Linking error:", err);
  //       });
  //     return false;
  //   }

  //   return true;
  // };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: "#ebf1f7" }}>
      {showWebView && link ? (
        <ArthpaySdkView
          source={link}
          style={{ flex: 1 }}
        />
      ) : (
        <View style={{ flex: 1, justifyContent: "flex-end", marginBottom: 50, alignItems: "center" }}>
          <Image
            source={{
              uri: "https://static.vecteezy.com/system/resources/thumbnails/012/487/870/small_2x/3d-icon-credit-card-mockup-floating-isolated-on-transparent-mobile-banking-and-online-payment-service-digital-marketing-e-commerce-withdraw-money-easy-shopping-cartoon-minimal-3d-render-png.png"
            }}
            style={{ resizeMode: "contain", width: "100%", height: "80%" }}
          />
          <TouchableOpacity
            onPress={paymentInitial}
            style={styles.payButton}
          >
            {!loading ? (
              <Text style={styles.buttonText}>PAY</Text>
            ) : (
              <ActivityIndicator size="small" color="#fff" />
            )}
          </TouchableOpacity>
        </View>
      )}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  buttonText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: '600',
    letterSpacing: 4
  },
  payButton: {
    width: 150,
    backgroundColor: "#1974D2",
    alignItems: "center",
    justifyContent: "center",
    padding: 10,
    borderRadius: 10
  },
  webView: {
    flex: 1,
    width: '100%',
  },
});

export default App;
