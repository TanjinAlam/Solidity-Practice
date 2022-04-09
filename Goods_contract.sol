// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.4.18 < 0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Deal {

  IERC20 public busd;

  /// The seller's address
  address public owner;

  /// The buyer's address part on this contract
  address public buyerAddr;

  /// The Buyer struct  
  struct Buyer {
    address addr;
    string name;

    bool init;
  }

  /// The Shipment struct
  struct Shipment {
    address courier;
    uint price;
    uint safepay;
    address payer;
    uint date;
    uint real_date;

    bool init;
  }

  /// The Order struct
  struct Order {
    string goods;
    uint quantity;
    uint number;
    uint price;
    uint safepay;
    Shipment shipment;

    bool init;
  }

  /// The Invoice struct
  struct Invoice {
    uint orderno;
    uint number;

    bool init;
  }

  /// The Photo struct
  struct Photo {
    uint orderno;
    string photoURL;
    string videoURL;
    address buyer;
    address manufacturer;
    address courier;
    Verification photoVerification;
    Verification videoVerification;
    bool init;
  }

 /// The Photo Verification struct
  struct Verification {
    bool isVerifiedByManufacturer;
    bool isVerifiedByCourier;
  }

  /// The mapping to store orders
  mapping (uint => Order) orders;

  /// The mapping to store invoices
  mapping (uint => Invoice) invoices;

  /// The mapping to store photos
  mapping (uint => Photo) photos;

  /// The sequence number of orders
  uint orderseq;

  /// The sequence number of invoices
  uint invoiceseq;

  /// Event triggered for every registered buyer
  event BuyerRegistered(address buyer, string name);

  /// Event triggered for every new order
  event OrderSent(address buyer, string goods, uint quantity, uint orderno);

  /// Event triggerd when the order gets valued and wants to know the value of the payment
  event PriceSent(address buyer, uint orderno, uint price, int8 ttype);

  /// Event trigger when the buyer performs the safepay
  event SafepaySent(address buyer, uint orderno, uint value, uint now);

  /// Event triggered when the seller sends the invoice
  event InvoiceSent(address buyer, uint invoiceno, uint orderno, uint delivery_date, address courier);

  /// Event triggered when the courie delivers the order
  event OrderDelivered(address buyer, uint invoiceno, uint orderno, uint real_delivey_date, address courier);

  /// Event triggered when the courie delivers the order
  event PhotoVerified(uint orderno, string photoURL, bool isPhotoVerified, bool isVideoVerified);



constructor () {
  busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
}

  /// The smart contract's constructor
  function Deall(address _buyerAddr) public {
    
    /// The seller is the contract's owner
    owner = msg.sender;

    buyerAddr = _buyerAddr;
  }


  /// The function to send purchase orders
  ///   requires fee
  ///   Payable functions returns just the transaction object, with no custom field.
  ///   To get field values listen to OrderSent event.
  function sendOrder(string memory goods, uint quantity, string memory photoURL, string memory videoURL) public {
    
    /// Accept orders just from buyer
    require(msg.sender == buyerAddr);

    /// Increment the order sequence
    orderseq++;

    /// Create the order register
    orders[orderseq] = Order(goods, quantity, orderseq, 0, 0, Shipment(address(this), 0, 0, address(this), 0, 0, false), true);
    photos[orderseq] = Photo(orderseq, photoURL, videoURL, buyerAddr, owner, address(this), Verification(false, false), Verification(false, false), true);

    /// Trigger the event
    emit OrderSent(msg.sender, goods, quantity, orderseq);

  }

  /// The function to query orders by number
  ///   Constant functions returns custom fields
  function queryOrder(uint number) public returns (address buyer, string memory goods, uint quantity, uint price, uint safepay, uint delivery_price, uint delivey_safepay) {
    
    /// Validate the order number
    require(orders[number].init);

    /// Return the order data
    return(buyerAddr, orders[number].goods, orders[number].quantity, orders[number].price, orders[number].safepay, orders[number].shipment.price, orders[number].shipment.safepay);
  }

  /// The function to send the price to pay for order
  ///  Just the owner can call this function
  ///  requires fee
  function sendPrice(uint orderno, uint price, int8 ttype) public{
  
    /// Only the owner can use this function
    require(msg.sender == owner);

    /// Validate the order number
    require(orders[orderno].init);

    /// Validate the type
    ///  1=order
    ///  2=shipment
    require(ttype == 1 || ttype == 2);

    if(ttype == 1){/// Price for Order

      /// Update the order price
      orders[orderno].price = price;

    } else {/// Price for Shipment

      /// Update the shipment price
      orders[orderno].shipment.price = price;
      orders[orderno].shipment.init  = true;
    }

    /// Trigger the event
    emit PriceSent(buyerAddr, orderno, price, ttype);

  }

  /// The function to send the value of order's price
  ///  This value will be blocked until the delivery of order
  ///  requires fee
  function sendSafepay(uint orderno) public {

    /// Validate the order number
    require(orders[orderno].init);

    /// Just the buyer can make safepay
    require(buyerAddr == msg.sender);

    /// The order's value plus the shipment value must equal to msg.value
    uint amount = orders[orderno].price + orders[orderno].shipment.price;

    orders[orderno].safepay = amount;


    address contract_address = address(this);
    
    /// transfering busd from the buyer to the smartcontract
    busd.approve(msg.sender, amount);
    busd.transferFrom(msg.sender, contract_address, amount);

    }

  /// The function to send the invoice data
  ///  requires fee
  function sendInvoice(uint orderno, uint delivery_date, address courier) public {

    /// Validate the order number
    require(orders[orderno].init);

    /// Just the seller can send the invoice
    require(owner == msg.sender);

    /// Validate the photo
    require(photos[orderno].init);

    invoiceseq++;

    /// Create then Invoice instance and store it
    invoices[invoiceseq] = Invoice(orderno, invoiceseq, true);

    /// Update the shipment data
    orders[orderno].shipment.date    = delivery_date;
    orders[orderno].shipment.courier = courier;

    photos[orderno].courier = courier;

    /// Trigger the event
    emit InvoiceSent(buyerAddr, invoiceseq, orderno, delivery_date, courier);
  }

  /// The function to get the sent invoice
  ///  requires no fee
  function getInvoice(uint invoiceno) public returns (address buyer, uint orderno, uint delivery_date, address courier){
  
    /// Validate the invoice number
    require(invoices[invoiceno].init);

    Invoice storage _invoice = invoices[invoiceno];
    Order storage _order = orders[_invoice.orderno];

    return (buyerAddr, _order.number, _order.shipment.date, _order.shipment.courier);
  }

  /// The function to mark an order as delivered
  function delivery(uint invoiceno, uint timestamp) public {
 
    /// Validate the invoice number
    require(invoices[invoiceno].init);
    
    Invoice storage _invoice = invoices[invoiceno];
    Order storage _order     = orders[_invoice.orderno];
    Photo storage _photo     = photos[_invoice.orderno];

    uint price = _order.price;

    uint seller_payout = _order.safepay / price;

    uint courier_payout = _order.shipment.safepay / price;

    uint price_ = seller_payout + courier_payout;

    // Validate the photo or Video verification
    require((_photo.photoVerification.isVerifiedByManufacturer && _photo.photoVerification.isVerifiedByCourier == true) ||
        (_photo.videoVerification.isVerifiedByManufacturer && _photo.videoVerification.isVerifiedByCourier == true));

    /// Just the courier can call this function
    require(_order.shipment.courier == msg.sender);

    emit OrderDelivered(buyerAddr, invoiceno, _order.number, timestamp, _order.shipment.courier);

    /// Payout the Order to the seller
    busd.approve(msg.sender, price_);
    busd.transfer(msg.sender, seller_payout);

    /// Payout the Shipment to the courier
    busd.transfer(_order.shipment.courier, courier_payout);

  }

    /// The function to mark an order as not delivered
  function refund(uint orderno, uint timestamp, uint invoiceno) public {

    Invoice storage _invoice = invoices[invoiceno];
    Order storage _order     = orders[_invoice.orderno];
    Photo storage _photo     = photos[_invoice.orderno];

    /// Validate the order number
    require(orders[orderno].init);

    uint amount = orders[orderno].safepay;

    // Validate the photo or Video verification
    require((_photo.photoVerification.isVerifiedByManufacturer && _photo.photoVerification.isVerifiedByCourier == false) ||
        (_photo.videoVerification.isVerifiedByManufacturer && _photo.videoVerification.isVerifiedByCourier == false));

    /// the buyer calls the function
    require(msg.sender == buyerAddr);

    /// payout the refund the buyer
    busd.transfer(msg.sender, amount);

  }


function SendPhotoVerification(uint orderno, int8 ptype) public {

    /// Validate the order number
    require(photos[orderno].init);
    
    /// Validate the seller
    require(photos[orderno].courier == msg.sender || photos[orderno].manufacturer == msg.sender);

    Photo storage _photo = photos[orderno];

    /// Validate the type
    ///  1=Photo Verification Request
    ///  2=Video Verification Request
    require(ptype == 1 || ptype == 2);

    if(ptype == 1){/// For Photo

        if(_photo.courier == msg.sender){ // if courier 

            /// Update the photo verification status  for courier
            _photo.photoVerification.isVerifiedByCourier = true;
        }else{ /// else manufacturer

            /// Update the photo verification status  for manufacturer
            _photo.photoVerification.isVerifiedByManufacturer = true;
        }
    } else {/// For Video

      if(_photo.courier == msg.sender){ // if courier 

            /// Update the vider verification status  for courier
            _photo.videoVerification.isVerifiedByCourier = true;
        }else{ /// else manufacturer

            /// Update the video verification status  for manufacturer
            _photo.videoVerification.isVerifiedByManufacturer = true;
        }
    }

    /// Trigger the event
    emit PhotoVerified(orderno, _photo.photoURL, (_photo.photoVerification.isVerifiedByCourier && _photo.photoVerification.isVerifiedByManufacturer), (_photo.videoVerification.isVerifiedByCourier && _photo.videoVerification.isVerifiedByManufacturer));

  }

  function health() pure public returns (string memory) {
    return "running";
  }
}