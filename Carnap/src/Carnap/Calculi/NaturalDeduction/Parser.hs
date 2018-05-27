module Carnap.Calculi.NaturalDeduction.Parser 
    ( toProofTreeStructuredFitch, toProofTreeHardegree, toProofTreeMontague, toProofTreeLemmon
    , toProofTreeFitch, toDeductionMontague, toDeductionFitch, toDeductionHardegree, toDeductionLemmon, toDeductionLemmonAlt ) where

import Carnap.Calculi.NaturalDeduction.Parser.Montague
import Carnap.Calculi.NaturalDeduction.Parser.Hardegree
import Carnap.Calculi.NaturalDeduction.Parser.Fitch
import Carnap.Calculi.NaturalDeduction.Parser.Lemmon
import Carnap.Calculi.NaturalDeduction.Parser.StructuredFitch
