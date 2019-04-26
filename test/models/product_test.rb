require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test 'product price must be positive' do
    product = Product.new(title: "Lorem book title",
                          description: "xys description",
                          image_url: "something.jpg")
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
    Product.new(title: "My Book Title",
                description: "yyy",
                price: 1,
                image_url: image_url)
  end

  test 'image url' do
    ok = %w{ fred.gif fred.jpeg fred.jpg fred.png FRED.JPG freD.Jpg
            http://a.b.c/x/y/z/fred.gif  }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }
    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't  be valid" # ambiguity observed, needs review
    end
    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be invalid" # ambiguity observed, needs review
    end
  end

  test 'product is not valid without a unique title' do
    product = Product.new(title: products(:three).title,
                          description: "yyy",
                          price: 1,
                          image_url: 'fed.gif')
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end

  test 'product is not valid without a unique title - i18n' do
    product = Product.new(title: products(:three).title,
                          description: "yyy",
                          price: 1,
                          image_url: 'fed.gif')
    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')],
                 product.errors[:title]
  end
end
