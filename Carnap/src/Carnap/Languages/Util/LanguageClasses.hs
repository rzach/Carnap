{-#LANGUAGE MultiParamTypeClasses, FunctionalDependencies, RankNTypes, FlexibleContexts, FlexibleInstances, TypeSynonymInstances, TypeOperators, GADTs, ScopedTypeVariables #-}
module Carnap.Languages.Util.LanguageClasses where

import Carnap.Core.Data.AbstractSyntaxDataTypes
import Carnap.Core.Data.Util (incArity)
import Carnap.Languages.Util.GenericConstructors
import Data.Typeable
import Control.Lens (Prism', prism',review,only)


--The convention for variables in this module is that lex is
--a lexicon, lang is language (without a particular associated syntactic
--type) and l is a language with an associated syntactic type

--------------------------------------------------------
--1. Constructor classes
--------------------------------------------------------

--------------------------------------------------------
--1.1 Connectives
--------------------------------------------------------

--these are classes for languages and with boolean connectives. 
class BooleanLanguage l where
            lneg :: l -> l
            land :: l -> l -> l
            lor  :: l -> l -> l
            lif  :: l -> l -> l
            liff :: l -> l -> l
            (.¬.) :: l -> l 
            (.¬.) = lneg
            (.-.) :: l -> l 
            (.-.) = lneg
            (.→.) :: l -> l -> l
            (.→.) = lif
            (.=>.) :: l -> l -> l
            (.=>.) = lif
            (.∧.) :: l -> l -> l
            (.∧.) = land
            (./\.) :: l -> l -> l
            (./\.) = land
            (.∨.) :: l -> l -> l
            (.∨.) = lor
            (.\/.) :: l -> l -> l
            (.\/.) = lor
            (.↔.) :: l -> l -> l
            (.↔.) = liff
            (.<=>.) :: l -> l -> l
            (.<=>.) = liff

class (Typeable b, PrismLink (FixLang lex) (Connective (BooleanConn b) (FixLang lex))) 
        => PrismBooleanConnLex lex b where

        _and :: Prism' (FixLang lex (Form b -> Form b -> Form b)) ()
        _and = binarylink_PrismBooleanConnLex . andPris 

        _or :: Prism' (FixLang lex (Form b -> Form b -> Form b)) ()
        _or = binarylink_PrismBooleanConnLex . orPris 

        _if :: Prism' (FixLang lex (Form b -> Form b -> Form b)) ()
        _if = binarylink_PrismBooleanConnLex . ifPris 

        _iff :: Prism' (FixLang lex (Form b -> Form b -> Form b)) ()
        _iff = binarylink_PrismBooleanConnLex . iffPris 

        _not :: Prism' (FixLang lex (Form b -> Form b)) ()
        _not = unarylink_PrismBooleanConnLex . notPris 

        binarylink_PrismBooleanConnLex :: 
            Prism' (FixLang lex (Form b -> Form b -> Form b)) 
                   (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b -> Form b))
        binarylink_PrismBooleanConnLex = link 

        unarylink_PrismBooleanConnLex :: 
            Prism' (FixLang lex (Form b -> Form b)) 
                   (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b))
        unarylink_PrismBooleanConnLex = link 

        andPris :: Prism' (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b -> Form b)) ()
        andPris = prism' (\_ -> Connective And ATwo) 
                          (\x -> case x of Connective And ATwo -> Just (); _ -> Nothing)

        orPris :: Prism' (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b -> Form b)) ()
        orPris = prism' (\_ -> Connective Or ATwo) 
                         (\x -> case x of Connective Or ATwo -> Just (); _ -> Nothing)

        ifPris :: Prism' (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b -> Form b)) ()
        ifPris = prism' (\_ -> Connective If ATwo) 
                         (\x -> case x of Connective If ATwo -> Just (); _ -> Nothing)

        iffPris :: Prism' (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b -> Form b)) ()
        iffPris = prism' (\_ -> Connective Iff ATwo) 
                          (\x -> case x of Connective Iff ATwo -> Just (); _ -> Nothing)

        notPris :: Prism' (Connective (BooleanConn b) (FixLang lex) (Form b -> Form b)) ()
        notPris = prism' (\_ -> Connective Not AOne) 
                          (\x -> case x of Connective Not AOne -> Just (); _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismBooleanConnLex lex b => BooleanLanguage (FixLang lex (Form b)) where
        lneg = review (unaryOpPrism _not)
        land = curry $ review (binaryOpPrism _and)
        lor  = curry $ review (binaryOpPrism _or)
        lif  = curry $ review (binaryOpPrism _if)
        liff = curry $ review (binaryOpPrism _iff)

class IndexedPropContextSchemeLanguage l where
            propCtx :: Int -> l -> l

class (Typeable b, PrismLink (FixLang lex) (Connective (PropositionalContext b) (FixLang lex))) 
        => PrismPropositionalContext lex b where

        _propCtxIdx :: Prism' (FixLang lex (Form b -> Form b)) Int
        _propCtxIdx = link_PropositionalContext . propCtxIdx

        link_PropositionalContext :: Prism' (FixLang lex (Form b -> Form b)) 
                                            (Connective (PropositionalContext b) (FixLang lex) (Form b -> Form b))
        link_PropositionalContext = link 

        propCtxIdx :: Prism' (Connective (PropositionalContext b) (FixLang lex) (Form b -> Form b)) Int
        propCtxIdx = prism' (\n -> Connective (PropCtx n) AOne) 
                            (\x -> case x of Connective (PropCtx n) AOne -> Just n
                                             _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismPropositionalContext lex b => IndexedPropContextSchemeLanguage (FixLang lex (Form b)) where
        propCtx n = review (unaryOpPrism (_propCtxIdx . only n))

class ModalLanguage l where
        nec :: l -> l
        pos :: l -> l

class (Typeable b, PrismLink (FixLang lex) (Connective (Modality b) (FixLang lex))) 
        => PrismModality lex b where

        _nec :: Prism' (FixLang lex (Form b -> Form b)) ()
        _nec = link_PrismModality . necPris

        _pos :: Prism' (FixLang lex (Form b -> Form b)) ()
        _pos = link_PrismModality . posPris 

        link_PrismModality :: 
            Prism' (FixLang lex (Form b -> Form b)) 
                   (Connective (Modality b) (FixLang lex) (Form b -> Form b))
        link_PrismModality = link 

        necPris :: Prism' (Connective (Modality b) (FixLang lex) (Form b -> Form b)) ()
        necPris = prism' (\_ -> Connective Box AOne) 
                          (\x -> case x of Connective Box AOne -> Just (); _ -> Nothing)

        posPris :: Prism' (Connective (Modality b) (FixLang lex) (Form b -> Form b)) ()
        posPris = prism' (\_ -> Connective Diamond AOne) 
                          (\x -> case x of Connective Diamond AOne -> Just (); _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismModality lex b => ModalLanguage (FixLang lex (Form b)) where
        nec = review (unaryOpPrism _nec)
        pos = review (unaryOpPrism _pos)

class BooleanConstLanguage l where 
        lverum :: l
        lfalsum :: l

class (Typeable b, PrismLink (FixLang lex) (Connective (BooleanConst b) (FixLang lex))) 
        => PrismBooleanConst lex b where

        _verum :: Prism' (FixLang lex (Form b)) ()
        _verum = link_BooleanConst . verumPris

        _falsum :: Prism' (FixLang lex (Form b)) ()
        _falsum = link_BooleanConst . falsumPris

        link_BooleanConst :: 
            Prism' (FixLang lex (Form b)) 
                   (Connective (BooleanConst b) (FixLang lex) (Form b))
        link_BooleanConst = link 

        verumPris :: Prism' (Connective (BooleanConst b) (FixLang lex) (Form b)) ()
        verumPris = prism' (\_ -> Connective Verum AZero) 
                          (\x -> case x of Connective Verum AZero -> Just (); _ -> Nothing)

        falsumPris :: Prism' (Connective (BooleanConst b) (FixLang lex) (Form b)) ()
        falsumPris = prism' (\_ -> Connective Falsum AZero) 
                          (\x -> case x of Connective Falsum AZero -> Just (); _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismBooleanConst lex b => BooleanConstLanguage (FixLang lex (Form b)) where
        lverum = review _verum ()
        lfalsum = review _falsum ()

--------------------------------------------------------
--1.2 Propositions
--------------------------------------------------------

--------------------------------------------------------
--1.2.1 Propositional Languages
--------------------------------------------------------
--languages with propositions
--TODO: derive IndexedPropLanguage from PrismPropLex

class IndexedPropLanguage l where
        pn :: Int -> l

class (Typeable b, PrismLink (FixLang lex) (Predicate (IntProp b) (FixLang lex))) 
        => PrismPropLex lex b where

        propIndex :: Prism' (FixLang lex (Form b)) Int
        propIndex = link_PrismPropLex . propIndex'

        link_PrismPropLex :: Prism' (FixLang lex (Form b)) (Predicate (IntProp b) (FixLang lex) (Form b))
        link_PrismPropLex = link 

        propIndex' :: Prism' (Predicate (IntProp b) (FixLang lex) (Form b)) Int
        propIndex' = prism' (\n -> Predicate (Prop n) AZero) 
                            (\x -> case x of Predicate (Prop n) AZero -> Just n
                                             _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismPropLex lex b => IndexedPropLanguage (FixLang lex (Form b)) where
        pn = review propIndex

class IndexedSchemePropLanguage l where
        phin :: Int -> l

class (Typeable b, PrismLink (FixLang lex) (Predicate (SchematicIntProp b) (FixLang lex))) 
        => PrismSchematicProp lex b where

        _sPropIdx :: Prism' (FixLang lex (Form b)) Int
        _sPropIdx = link_PrismSchematicProp . sPropIdx

        link_PrismSchematicProp :: Prism' (FixLang lex (Form b)) (Predicate (SchematicIntProp b) (FixLang lex) (Form b))
        link_PrismSchematicProp = link 

        sPropIdx :: Prism' (Predicate (SchematicIntProp b) (FixLang lex) (Form b)) Int
        sPropIdx = prism' (\n -> Predicate (SProp n) AZero) 
                           (\x -> case x of Predicate (SProp n) AZero -> Just n
                                            _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismSchematicProp lex b => IndexedSchemePropLanguage (FixLang lex (Form b)) where
        phin = review _sPropIdx

--------------------------------------------------------
--1.2.2 Predicate Languages
--------------------------------------------------------
--languages with predicates

class PolyadicPredicateLanguage lang arg ret where
        ppn :: Typeable ret' => Int -> Arity arg ret n ret' -> lang ret'

class (Typeable c, Typeable b, PrismLink (FixLang lex) (Predicate (IntPred b c) (FixLang lex))) 
        => PrismPolyadicPredicate lex c b where

        _predIdx :: Typeable ret => Arity (Term c) (Form b) n ret -> Prism' (FixLang lex ret) Int
        _predIdx a = link_PrismPolyadicPredicate . (predIndex a)

        link_PrismPolyadicPredicate :: Typeable ret => Prism' (FixLang lex ret) (Predicate (IntPred b c) (FixLang lex) ret)
        link_PrismPolyadicPredicate = link 

        predIndex :: Arity (Term c) (Form b) n ret -> Prism' (Predicate (IntPred b c) (FixLang lex) ret) Int
        predIndex a = prism' (\n -> Predicate (Pred a n) a) 
                             (\x -> case x of (Predicate (Pred a' n) a'') | arityInt a == arityInt a' -> Just n
                                              _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismPolyadicPredicate lex c b => PolyadicPredicateLanguage (FixLang lex) (Term c) (Form b) where
        ppn n a = review (_predIdx a) n

class EqLanguage l t where
        equals :: t -> t -> l

class (Typeable c, Typeable b, PrismLink (FixLang lex) (Predicate (TermEq b c) (FixLang lex))) 
        => PrismTermEquality lex c b where

        _termEq :: Prism' (FixLang lex (Term c -> Term c -> Form b)) ()
        _termEq = link_TermEquality . termEq

        link_TermEquality :: Prism' (FixLang lex (Term c -> Term c -> Form b)) 
                                    (Predicate (TermEq b c) (FixLang lex) (Term c -> Term c -> Form b))
        link_TermEquality = link 

        termEq :: Prism' (Predicate (TermEq b c) (FixLang lex) (Term c -> Term c -> Form b)) ()
        termEq = prism' (\n -> Predicate TermEq ATwo) 
                           (\x -> case x of Predicate TermEq ATwo -> Just ()
                                            _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismTermEquality lex c b => EqLanguage (FixLang lex (Form b)) (FixLang lex (Term c)) where
        equals = curry $ review (binaryOpPrism _termEq)

--------------------------------------------------------
--1.3. Terms
--------------------------------------------------------

class IndexedConstantLanguage l where
        cn :: Int -> l

class (Typeable b, PrismLink (FixLang lex) (Function (IntConst b) (FixLang lex))) 
        => PrismIndexedConstant lex b where

        _constIdx :: Prism' (FixLang lex (Term b)) Int
        _constIdx = link_IndexedConstant . constIndex

        link_IndexedConstant :: Prism' (FixLang lex (Term b)) (Function (IntConst b) (FixLang lex) (Term b))
        link_IndexedConstant = link 

        constIndex :: Prism' (Function (IntConst b) (FixLang lex) (Term b)) Int
        constIndex = prism' (\n -> Function (Constant n) AZero) 
                            (\x -> case x of Function (Constant n) AZero -> Just n
                                             _ -> Nothing)

instance {-#OVERLAPPABLE#-} PrismIndexedConstant lex b => IndexedConstantLanguage (FixLang lex (Term b)) where
       cn = review _constIdx

class IndexedSchemeConstantLanguage l where
        taun :: Int -> l

class PolyadicFunctionLanguage lang arg ret where
        pfn :: Typeable ret' => Int -> Arity arg ret n ret' -> lang ret'

class (Typeable c, Typeable b, PrismLink (FixLang lex) (Function (IntFunc b c) (FixLang lex))) 
        => PrismPolyadicFunction lex c b where

        _funcIdx :: Typeable ret => Arity (Term c) (Term b) n ret -> Prism' (FixLang lex ret) Int
        _funcIdx a = link_PrismPolyadicFunction . (funcIndex a)

        link_PrismPolyadicFunction :: Typeable ret => Prism' (FixLang lex ret) (Function (IntFunc b c) (FixLang lex) ret)
        link_PrismPolyadicFunction = link 

        funcIndex :: Arity (Term c) (Term b) n ret -> Prism' (Function (IntFunc b c) (FixLang lex) ret) Int
        funcIndex a = prism' (\n -> Function (Func a n) a) 
                             (\x -> case x of (Function (Func a' n) a'') | arityInt a == arityInt a' -> Just n
                                              _ -> Nothing)

--------------------------------------------------------
--1.4. Quantifiers
--------------------------------------------------------

class QuantLanguage l t where
        lall  :: String -> (t -> l) -> l
        lsome :: String -> (t -> l) -> l

class (Typeable b, Typeable c, PrismLink (FixLang lex) (Quantifiers (StandardQuant b c) (FixLang lex))) 
        => PrismStandardQuant lex b c where

        _all :: Prism' (FixLang lex ((Term c -> Form b) -> Form b)) String
        _all = link_standardQuant . qall

        _some :: Prism' (FixLang lex ((Term c -> Form b) -> Form b)) String
        _some = link_standardQuant . qsome

        link_standardQuant :: Prism' (FixLang lex ((Term c -> Form b) -> Form b)) 
                               (Quantifiers (StandardQuant b c) (FixLang lex) ((Term c -> Form b) -> Form b))
        link_standardQuant = link 

        qall :: Prism' (Quantifiers (StandardQuant b c) (FixLang lex) ((Term c -> Form b) -> Form b)) String
        qall = prism' (\s -> Bind (All s))
                      (\x -> case x of (Bind (All s)) -> Just s
                                       _ -> Nothing)

        qsome :: Prism' (Quantifiers (StandardQuant b c) (FixLang lex) ((Term c -> Form b) -> Form b)) String
        qsome = prism' (\s -> Bind (Some s))
                       (\x -> case x of (Bind (Some s)) -> Just s
                                        _ -> Nothing)

-------------------
--  1.5 Exotica  --
-------------------

class IndexingLang lex index indexed unindexed | lex -> indexed unindexed where
    atWorld :: FixLang lex unindexed -> FixLang lex index -> FixLang lex indexed
    world :: Int -> FixLang lex index
    worldScheme :: Int -> FixLang lex index

class (Typeable a, Typeable b, Typeable c, PrismLink (FixLang lex) (Indexer a b c (FixLang lex))) 
        => PrismIndexing lex a b c where

        _indexer :: Prism' (FixLang lex (Form b -> Term a -> Form c)) ()
        _indexer = link_indexer . indexer

        link_indexer :: Prism' (FixLang lex (Form b -> Term a -> Form c)) 
                               (Indexer a b c (FixLang lex) (Form b -> Term a -> Form c))
        link_indexer = link 

        indexer :: Prism' (Indexer a b c (FixLang lex) (Form b -> Term a -> Form c)) ()
        indexer = prism' (const AtIndex) (const (Just ()))

class (Typeable b, PrismLink (FixLang lex) (Function (Cons b) (FixLang lex))) 
        => PrismCons lex b where

        _cons :: Prism' (FixLang lex (Term b -> Term b -> Term b)) ()
        _cons = link_cons . cons

        link_cons :: Prism' (FixLang lex (Term b -> Term b -> Term b)) 
                            (Function (Cons b) (FixLang lex) (Term b -> Term b -> Term b))
        link_cons = link 

        cons :: Prism' (Function (Cons b) (FixLang lex) (Term b -> Term b -> Term b)) ()
        cons = prism' (const (Function Cons ATwo )) (const (Just ()))

--------------------------------------------------------
--2. Utility Classes
--------------------------------------------------------

class Incrementable lex arg where
        incHead :: FixLang lex a -> Maybe (FixLang lex (arg -> a)) 
        incBody :: (Typeable b, Typeable arg) => FixLang lex (arg -> b) -> Maybe (FixLang lex (arg -> arg -> b))
        incBody = incArity incHead
