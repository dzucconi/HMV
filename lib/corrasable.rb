class Corrasable
  attr_reader :text

  def initialize(text)
    @text = self.class.sanitize(text)
  end

  def to_phonemes
    Typhoeus::Request.new('api.corrasable.com/phonemes',
      method: :post,
      params: {
        text: text
      }
    ).run.let do |response|
      res = Oj
        .load(response.body)
        .flatten(1) # Flatten outer array since we have no concept of lines
        .map { |word| word.split(' ') } # Split each word into an array of phonemes
        .zip(text.split(' '))
        .map { |phonemes, word|
          # Cast the word/phonemes, include a pause
          [Word.new(word, phonemes), Word.new(' ', [' '])]
        }
        .flatten

      res.first(res.size - 1) # Strip the last pause
    end
  end

  def self.sanitize(string)
    string.to_s
      .gsub(/[^a-z ]/i, '') # Avoid punctuation and numbers for the time being
  end
end
