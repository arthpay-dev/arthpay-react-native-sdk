import { CreateOrderRequest } from "./CreateOrderRequest";
import { BASE_URL } from "./Config";
export class ArthPayMerchant {
    private clientId: string;
    private clientSecret: string;
  
    constructor(clientId: string, clientSecret: string) {
      this.clientId = clientId;
      this.clientSecret = clientSecret;
    }
  
    // Method to create an order
    async createOrder(orderObj: CreateOrderRequest): Promise<string> {
        let headers = {
            'content-type': 'application/json',
            'x-client-id': this.clientId,
            'x-client-secret': this.clientSecret

        }

      const get_order_url_api=await fetch(`${BASE_URL}/orderCreate`,{
        method:'POST',
        headers:headers,
        body:JSON.stringify(orderObj)
      })

      const get_order_url_response=await get_order_url_api.json()
      return JSON.stringify(get_order_url_response)
    }
  }

  