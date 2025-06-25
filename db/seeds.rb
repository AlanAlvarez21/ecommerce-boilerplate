Category.destroy_all
Category.create!([
  {
    id: "79438cd4-5bcb-410b-bd02-2c71a313b92d",
    name: "Monedas Oro",
    description: "Categoría Monedas de Oro",
    image: nil,
    image_url: "https://www.banxico.org.mx/multimedia/rev_1kg_oro...."
  },
  {
    id: "01b3b429-9a07-4cc2-960e-55d6ecd8cec3",
    name: "Plata",
    description: "Categoría Monedas de Plata",
    image: nil,
    image_url: "https://www.banxico.org.mx/multimedia/quijoteanv.p..."

  },
  {
    id: "c4b1e2bd-d755-40a6-9274-d1d5d6d31b53",
    name: "Numismática",
    description: "Colección Numismática",
    image: nil,
    image_url: "https://www.banxico.org.mx/multimedia/busto.png"
  },
  {
    id: "0cd3a722-89d0-452a-9a39-8948322e4e89",
    name: "Billetes",
    description: "Colección de Billetes",
    image: nil,
    image_url: "https://www.banxico.org.mx/multimedia/famG_tamanio..."
  }
])

puts "--- Finished seeding Categories --"

Product.destroy_all
Product.create!([
  {
    name: "Centenario Oro Demo 1",
    description: "Centenario Oro Demo 1",
    price: 62000,
    category_id: "79438cd4-5bcb-410b-bd02-2c71a313b92d",
    active: true,
    image_url: "https://www.banxico.org.mx/multimedia/rev_1kg_oro...."
  },
  {
    name: "Centenario Plata Demo 2",
    description: "Centenario Plata Demo 2",
    price: 500,
    category_id: "01b3b429-9a07-4cc2-960e-55d6ecd8cec3",
    active: false,
    image_url: "https://www.banxico.org.mx/multimedia/CentenarioRe..."
  },
  {
    name: "Centenario Oro 2",
    description: "Centenario Oro 2",
    price: 52000,
    category_id: "79438cd4-5bcb-410b-bd02-2c71a313b92d",
    active: true,
    image_url: "https://www.banxico.org.mx/multimedia/rev_1kg_oro...."
  },
  {
    name: "Centenario Plata Demo 1",
    description: "Centenario Plata Demo 1",
    price: 500,
    category_id: "01b3b429-9a07-4cc2-960e-55d6ecd8cec3",
    active: false,
    image_url: "https://www.banxico.org.mx/multimedia/CentenarioRe..."
  }
])

puts " --- Finished seeding Products ---"
