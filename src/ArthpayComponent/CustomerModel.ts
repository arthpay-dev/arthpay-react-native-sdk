export class CustomerModel {
    firstName: string = '';
    lastName: string = '';
    street: string = '';
    city: string = '';
    state: string = '';
    zipCode: string = '';
    email: string = '';
    mobileNo: string = '';
  
    setFirstName(firstName: string): void {
      this.firstName = firstName;
    }
  
    setLastName(lastName: string): void {
      this.lastName = lastName;
    }
  
    setChAddrStreet(street: string): void {
      this.street = street;
    }
  
    setChAddrCity(city: string): void {
      this.city = city;
    }
  
    setChAddrState(state: string): void {
      this.state = state;
    }
  
    setChAddrZip(zipCode: string): void {
      this.zipCode = zipCode;
    }
  
    setChEmail(email: string): void {
      this.email = email;
    }
  
    setChMobile(mobileNo: string): void {
      this.mobileNo = mobileNo;
    }
  }