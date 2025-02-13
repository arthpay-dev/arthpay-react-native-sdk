import React, { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { ArthPayMerchant, ArthpaySdkView, CreateOrderRequest, CustomerModel, OrderModel } from 'arthpay-sdk'

const App = () => {
  const [link, setLink] = useState("")

  useEffect(() => {
    (async () => {
      const arthpay = new ArthPayMerchant([CLIENT_ID], [CLIENT_SECRET])
      const order_info = new OrderModel()
      order_info.setOrderInfo("1231231")
      order_info.setCurrency("INR")
      order_info.setAmount("100")

      const customerDetails = new CustomerModel()
      customerDetails.setFirstName("John");
      customerDetails.setLastName("Doe");
      customerDetails.setChAddrStreet("John Nagar Road");
      customerDetails.setChAddrCity("Mumbai");
      customerDetails.setChAddrState("Maharashtra");
      customerDetails.setChAddrZip("400001");
      customerDetails.setChEmail("support@arthpay.com");
      customerDetails.setChMobile("+919999999999");

      const orderRequest = new CreateOrderRequest(customerDetails, order_info, [REDIRECTION_URL])

      let link = await arthpay.createOrder(orderRequest)
      link = JSON.parse(link)
      setLink(link?.obj)

    })()


  }, [])

  return (
    <View style={styles.container}>
      <ArthpaySdkView
        style={styles.webView}
        source={link} // The URL to load in the WebView
      />

    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  webView: {
    flex: 1,
  },
});

export default App;
