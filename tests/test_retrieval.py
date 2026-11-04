import unittest
from zero_faith import scan

class ReviewTests(unittest.TestCase):
    def test_opt_in(self):
        self.assertEqual(scan("Atomwaffen Division"),[])
    def test_known_reference(self):
        hits=scan("Report about Atomwaffen Division",True)
        self.assertTrue(hits)
        self.assertTrue(all(h['interpretation']=='literal_mention_only' for h in hits))
    def test_research_disabled(self):
        self.assertEqual(scan("IMVE",True),[])
        self.assertTrue(scan("IMVE",True,True))
    def test_ordinary_belief(self):
        self.assertEqual(scan("Islam Christianity Sikhism Judaism atheism peaceful protest",True),[])
    def test_number_boundaries(self):
        self.assertEqual(scan("17640",True),[])
    def test_german(self):
        self.assertTrue(scan("Reichsbürger",True))
    def test_normalization(self):
        self.assertTrue(scan("ＡＴＯＭＷＡＦＦＥＮ ＤＩＶＩＳＩＯＮ",True))

if __name__=='__main__':unittest.main()
