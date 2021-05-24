require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:image_url].any?
    assert product.errors[:price].any?
  end
  
  test "product price must be positive" do 
    product = Product.new(title: "My book title", 
                          description: "yyy",
                          image_url: "zzz.jpg",)
      product.price = -1
      assert product.invalid?
      assert_equal ["must be greater than or equal to 0.01"],
      product.errors[:price]
      
      product.price = 0
      assert product.invalid?
      assert_equal ["must be greater than or equal to 0.01"],
      product.errors[:price]
      
      product.price = 1
      assert product.valid?
  end

  def new_product(image_url)
    Product.new(title: "My book title",
                description: "yyy",
                price: 1,
                image_url: image_url)
  end

  test "image url" do
    ok = %w( fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg 
              http://a.b.c/x/y/z/fred.gif )
    bad = %w( fred.doc fred.gif/more fred.gif.more )

    ok.each do |image_url|
      assert new_product(image_url).valid?,
              "#{image_url} shouldn't be invalid"
    end

    bad.each do |image_url|
      assert new_product(image_url).invalid?,
              "#{image_url} shouldn't be valid"
    end

  end

  test "product is not valid without a unique title" do
    product = Product.new(title: products(:ruby).title,
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end

  test "product is not valid without a unique title i18n" do
    product = Product.new(title: products(:ruby).title,
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?
    assert_equal [I18n.translate('error.message.taken')], 
                  product.errors[:title]
  end

  test "product should have a title greater than 10 and smaller than 100 characters" do

    def generate_title(size)
      array_of_elements = []
      for i in 1..size
        array_of_elements << rand(1...10)
      end
      generated_title = array_of_elements.join.to_s
      return generated_title
    end
    product = Product.new(title: generate_title(9),
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?
    assert_equal ["has less than 10 characters"], product.errors[:title]

    product = Product.new(title: generate_title(10),
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.valid?
    assert_equal ["hasn't 10 characters"], product.errors[:title]

    product = Product.new(title:  generate_title(101),
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?
    assert_equal ["has more than 100 characters"], product.errors[:title]

    product = Product.new(title:  generate_title(100),
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.valid?
    assert_equal ["hasn't 100 characters"], product.errors[:title]
  end
end

