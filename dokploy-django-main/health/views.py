from django.http import JsonResponse
from django.views.decorators.http import require_GET
from django.views.decorators.csrf import csrf_exempt
import json

@require_GET
@csrf_exempt
def health_check(request):
    """
    Simple health check endpoint for Dokploy monitoring
    """
    return JsonResponse({
        'status': 'healthy',
        'service': 'Django API',
        'version': '1.0.0',
        'message': 'Service is running normally'
    })

@require_GET  
@csrf_exempt
def info(request):
    """
    Basic info endpoint
    """
    return JsonResponse({
        'name': 'Dokploy Django Template',
        'description': 'Minimal Django template for Dokploy deployment',
        'version': '1.0.0',
        'framework': 'Django 5.2.7'
    })
