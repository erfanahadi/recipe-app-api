"""Test the ingredients API"""
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from rest_framework.test import APIClient
from rest_framework import status

from core.models import Ingredient
from recipe.serializers import IngredientSerializer

INGREDIAENTS_URL = reverse('recipe:ingredient-list')

def detail_url(ingredient_id):
    """Return ingredient detail URL"""
    return reverse('recipe:ingredient-detail', args=[ingredient_id])

def create_user(email='user@example.com', password='testpass123'):
    return get_user_model().objects.create_user(email=email, password=  password)

class PublicIngredientsApiTests(TestCase):
    """Test the publicly available ingredients API"""

    def setUp(self):
        self.client = APIClient()

    def test_auth_required(self):
        """Test that authentication is required"""
        res = self.client.get(INGREDIAENTS_URL)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

class PrivateIngredientsApiTests(TestCase):
    """Test the authorized user ingredients API"""
    def setUp(self):
        self.client = APIClient()
        self.user = create_user()
        self.client.force_authenticate(self.user)

    def test_retrieve_ingredients(self):
        """Test retrieving a list of ingredients"""
        Ingredient.objects.create(user=self.user, name='Ingredient1')
        Ingredient.objects.create(user=self.user, name='Ingredient2')
        res = self.client.get(INGREDIAENTS_URL)
        ingredients = Ingredient.objects.all().order_by('-name')
        serializer = IngredientSerializer(ingredients, many=True)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data, serializer.data)

    def test_ingredients_limited_to_user(self):
        """Test that ingredients returned are for the authenticated user"""
        user2 = create_user(email='user2@example.com', password='testpass123')
        Ingredient.objects.create(user=user2, name='Ingredient3')
        ingredient = Ingredient.objects.create(user=self.user, name='Ingredient4')
        res = self.client.get(INGREDIAENTS_URL)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(len(res.data), 1)
        self.assertEqual(res.data[0]['name'], ingredient.name)
        self.assertEqual(res.data[0]['id'], ingredient.id)

    def test_update_ingredient_successful(self):
        """Test updating an ingredient is successful"""
        ingredient = Ingredient.objects.create(user=self.user, name='Ingredient1')
        payload = {'name': 'Ingredient2'}
        url = detail_url(ingredient.id)
        res = self.client.patch(url, payload)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        ingredient.refresh_from_db()
        self.assertEqual(ingredient.name, payload['name'])

    def test_delete_ingredient_successful(self):
        """Test deleting an ingredient is successful"""
        ingredient = Ingredient.objects.create(user=self.user, name='Ingredient1')
        url = detail_url(ingredient.id)
        res = self.client.delete(url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        ingredients = Ingredient.objects.filter(user=self.user)
        self.assertFalse(ingredients.exists())
